//
//  DetailViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 06/03/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import CDKSwiftOracc


class TextEditionViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var stackView: UIStackView!
    
    static let defaultFormattingPreferences: OraccTextEdition.FormattingPreferences = UIFont.defaultFont.makeDefaultPreferences()
    

    
    var textItem: OraccCatalogEntry?
    weak var parentController: ProjectListViewController?
    weak var catalogue: CatalogueProvider?
    
    var textStrings: TextEditionStringContainer? {
        didSet {
            textStrings?.render(withPreferences: TextEditionViewController.defaultFormattingPreferences)
        }
    }
    
    enum TextDisplay: Int {
        case Cuneiform, Transliteration, Normalisation, Translation
    }
    
    enum DisplayState {
        case single(TextDisplay)
        case double(left: TextDisplay, right: TextDisplay)
    }
    
    var displayState: DisplayState? = nil {
        didSet {
            refreshState()
        }
    }
    
    func refreshState(leftOffSet: CGPoint? = nil, rightOffSet: CGPoint? = nil) {
        guard let state = self.displayState else {return}
        switch state {
        case .single(let textState):
            guard let textView = self.stackView.subviews[0].subviews.first as? UITextView else {return}
            switchTextTo(textState, textView: textView)
            
            guard let control = self.stackView.subviews[0].subviews.last as? UISegmentedControl else {return}
            control.selectedSegmentIndex = textState.rawValue
            
            if let offset = leftOffSet {
                textView.setContentOffset(offset, animated: false)
            }
            
        case .double(let left, let right):
            guard let leftView = self.stackView.subviews[0].subviews.first as? UITextView else {return}
            guard let rightView = self.stackView.subviews[1].subviews.first as? UITextView else {return}
            
            switchTextTo(left, textView: leftView)
            switchTextTo(right, textView: rightView)
            
            guard let leftControl = self.stackView.subviews[0].subviews.last as? UISegmentedControl else {return}
            guard let rightControl = self.stackView.subviews[1].subviews.last as? UISegmentedControl else {return}
            
            leftControl.selectedSegmentIndex = left.rawValue
            rightControl.selectedSegmentIndex = right.rawValue
            
            if let offset = leftOffSet {
                leftView.setContentOffset(offset, animated: false)
            }
            
            if let offset = rightOffSet {
                rightView.setContentOffset(offset, animated: false)
            }
        }
    }
    
    
    var searchTerm: String? = nil
    
    func addInfoButton() {
        let info = UIButton(type: .infoLight)
        info.addTarget(self, action: #selector(presentInformation), for: UIControlEvents.touchUpInside)
        let infoBarButton = UIBarButtonItem(customView: info)
        navigationItem.rightBarButtonItem = infoBarButton
    }
    

    
    
    
    @objc func presentInformation() {
        guard let catalogueInfo = self.textItem else {return}
        guard let infoTableController = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.InfoTableViewController) as? InfoTableViewController else {return}
        infoTableController.catalogueInfo = catalogueInfo
        infoTableController.textEditionViewController = self
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            infoTableController.modalPresentationStyle = .popover
            present(infoTableController, animated: true)
            let popoverController = infoTableController.popoverPresentationController
            popoverController?.barButtonItem = self.navigationItem.rightBarButtonItem
        } else {
            navigationController?.pushViewController(infoTableController, animated: true)
        }
        
        
    }
    
    func makeNavigationButtons() -> (UIBarButtonItem, UIBarButtonItem) {
        let left = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(navigate(_:)))
        let right = UIBarButtonItem(title: ">", style: .plain, target: self, action: #selector(navigate(_:)))
        
        return (left, right)
    }
    
    
    // TODO :- Refactor grotesquely horrible navigation.
    @objc func navigate(_ sender: Any) {
        guard let catalogue = self.catalogue else { return }
        guard let id = self.textItem?.id else { return }
        guard let currentRow = catalogue.texts.index(where: {$0.id == id}) else {return}
        let nextRow: Int
        var direction: Navigate? = nil
        
        if let button = sender as? UIBarButtonItem {
            if button.title == "<" {
                direction = .left
            } else if button.title == ">" {
                direction = .right
            }
        } else if let keyCommand = sender as? UIKeyCommand {
            switch keyCommand.input {
            case UIKeyInputLeftArrow:
                direction = .left
            case UIKeyInputRightArrow:
                direction = .right
            default:
                return
            }
        }
        
        
        if let direction = direction {
            switch direction {
            case .left:
                nextRow = currentRow - 1
                guard nextRow >= catalogue.texts.startIndex else {return}
            case .right:
                nextRow = currentRow + 1
                guard nextRow < catalogue.texts.endIndex else {return}
            }
            
            guard let nextEntry = catalogue.text(at: nextRow) else {return}
            guard let strings = sqlite.getTextStrings(nextEntry.id) else {return}
            
            self.textStrings = strings
            self.textItem = nextEntry
            self.title = nextEntry.title
            self.configureStackViews()
            
            if traitCollection.horizontalSizeClass == .regular {
                if direction == .left {
                    parentController?.navigate(.left)
                } else {
                    parentController?.navigate(.right)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        navigationItem.title = textItem?.title
        stackView.distribution = .fillEqually
        let leftColumn = UIStackView.makeTextStackView(textViewTag: 0, controlTag: 0)
        let rightColumn = UIStackView.makeTextStackView(textViewTag: 1, controlTag: 1)
        stackView.addArrangedSubview(leftColumn)

        guard let margins = leftColumn.superview?.layoutMarginsGuide else {return}
        leftColumn.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        leftColumn.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        stackView.addArrangedSubview(rightColumn)
        
        
        configureStackViews()
        initialiseToolbar()
        addInfoButton()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    func configureStackViews() {
        if self.stackView.arrangedSubviews.count == 1 {
            guard let view = stackView.arrangedSubviews.first as? UIStackView else {return}
            guard let textView = view.arrangedSubviews[0] as? UITextView else {return}
            guard let segmentedControl = view.arrangedSubviews[1] as? UISegmentedControl else {return}
            
            textView.attributedText = textStrings?.normalisation
            if let searchTerm = searchTerm {
                highlightSearchTerm(searchTerm, in: textView)
            }
            segmentedControl.selectedSegmentIndex = 2
            segmentedControl.addTarget(self, action: #selector(changeText), for: .valueChanged)
           self.displayState = DisplayState.single(.Normalisation)
            
            
        } else if self.stackView.arrangedSubviews.count == 2 {
            guard let leftView = stackView.arrangedSubviews[0] as? UIStackView else {return}
            guard let rightView = stackView.arrangedSubviews[1] as? UIStackView else {return}
            
            guard let leftTextView = leftView.arrangedSubviews[0] as? UITextView else {return}
            guard let leftControl =  leftView.arrangedSubviews[1] as? UISegmentedControl else {return}
            leftTextView.attributedText = textStrings?.normalisation
            if let searchTerm = searchTerm {
                highlightSearchTerm(searchTerm, in: leftTextView)
            }
            
            leftControl.selectedSegmentIndex = 2
            leftControl.addTarget(self, action: #selector(changeText), for: .valueChanged)
            
            
            guard let rightTextView = rightView.arrangedSubviews[0] as? UITextView else {return}
            guard let rightControl = rightView.arrangedSubviews[1] as? UISegmentedControl else {return}
            rightTextView.text = textStrings?.translation
            rightControl.selectedSegmentIndex = 3
            rightControl.addTarget(self, action: #selector(changeText), for: .valueChanged)
            
            self.displayState = DisplayState.double(left: .Normalisation,
                                                    right: .Translation)
            
            
            stackView.distribution = .fillEqually
        }
    }
    
    func initialiseToolbar() {
        let quickDefine = UIBarButtonItem(title: "Quick define", style: .plain, target: parentController, action: #selector(ProjectListViewController.showGlossary(_:)))
        let (left, right) = makeNavigationButtons()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.setToolbarItems([quickDefine, spacer, left, right], animated: true)
    }
    
    
    func configureToolBar(withText text: String) {
        guard let quickDefineLabel = toolbarItems?.first else {return}
        quickDefineLabel.title = text
    }
    
    @objc func openInGlossary() {
        
    }
    
    
    @IBAction func changeText(_ sender: UISegmentedControl) {
        guard let displayState = self.displayState else {return}
        let newState: TextDisplay
        switch sender.selectedSegmentIndex {
        case 0:
            newState = .Cuneiform
        case 1:
            newState = .Transliteration
        case 2:
            newState = .Normalisation
        case 3:
            newState = .Translation
        default:
            newState = .Normalisation
        }
        
        
        switch displayState {
        case .single(_):
            self.displayState = DisplayState.single(newState)
            
        case .double(let leftDisplay, let rightDisplay):
            let newDisplayState: DisplayState
            
            switch sender.tag {
            case 0: // Changing the left display's text
                newDisplayState = DisplayState.double(left: newState, right: rightDisplay)
                
            case 1: // Changing the right display's text
                newDisplayState = DisplayState.double(left: leftDisplay, right: newState)
                
            default: // Big error
                return
            }
            
            
            self.displayState = newDisplayState
            
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        // All kinds of cryptic safety checks which need refactoring.
        let selectedRange = textView.selectedRange
        guard let textRange = textView.selectedTextRange else {return}
        guard let text = textView.text(in: textRange) else {return}
        guard  text != "" else { return }
        
        let selection = textView.attributedText.attributedSubstring(from: selectedRange)
        let attributes = selection.attributes(at: 0, effectiveRange: nil)
        let guideWord = attributes[.oraccGuideWord] as? String
        let word = attributes[.oraccCitationForm] as? String
        let sense = attributes[.oraccSense] as? String
        let partOfSpeech = attributes[.partOfSpeech] as? String
        let writtenForm = attributes[.writtenForm] as? String
        
        let detailString =  "\(word ?? ""): \(guideWord ?? ""), \(sense ?? "") \(partOfSpeech ?? "") \(writtenForm ?? "")"
        
        configureToolBar(withText: detailString)
    }
    
    func viewOnline() {
        guard let catalogueInfo = self.textItem else {return}
        let textID = catalogueInfo.id
        let projectPath = catalogueInfo.project
        let url = URL(string: "http://oracc.org/\(projectPath)/\(textID)/html")!
        
        let webView = OnlineViewController()
        webView.url = url
        
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    func highlightSearchTerm(_ searchTerm: String, in textView: UITextView) {
        textView.textStorage.enumerateAttribute(.oraccCitationForm, in: NSMakeRange(0, textView.textStorage.length), options: .longestEffectiveRangeNotRequired, using: {
            value, range, stop in
            guard let stringVal = value as? String else {return}
            if searchTerm.lowercased() == stringVal.lowercased() {
                guard range.length > 2 else {return}
                let newRange = NSMakeRange(range.location, range.length - 1)
                textView.textStorage.addAttributes([NSAttributedStringKey.backgroundColor: UIColor.yellow], range: newRange)
            }
        })
    }
    
    
    func switchTextTo(_ text: TextDisplay, textView: UITextView) {
        switch text {
        case .Cuneiform:
            textView.text = textStrings?.cuneiform
            textView.font = UIFont.cuneiformNA
            textView.delegate = nil
        case .Transliteration:
            textView.attributedText = textStrings?.transliteration
            textView.delegate = nil
        case .Normalisation:
            textView.attributedText = textStrings?.normalisation
            textView.delegate = self
            if let searchTerm = searchTerm {
                highlightSearchTerm(searchTerm, in: textView)
            }
        case .Translation:
            textView.font = UIFont.defaultFont
            textView.text = textStrings?.translation
            textView.delegate = nil
        }
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let leftColumn = stackView.arrangedSubviews[0]
        let rightColumn = stackView.arrangedSubviews[1]
        
        switch traitCollection.horizontalSizeClass {
        case .regular:
            leftColumn.isHidden = false
            rightColumn.isHidden = false
            
        default:
            leftColumn.isHidden = false
            rightColumn.isHidden = true
            
        }
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        if let displayState = displayState {
            switch displayState {
            case .single(let state):
                coder.encode(true, forKey: "isSingle")
                coder.encode(state.rawValue, forKey: "leftState")
                coder.encode(-1, forKey: "rightState")
                if let view = self.stackView.subviews[0].subviews.first as? UITextView {
                    let position = view.contentOffset
                    coder.encode(position, forKey: "leftOffset")
                }
                
            case .double(let left, let right):
                coder.encode(left.rawValue, forKey: "leftState")
                coder.encode(right.rawValue, forKey: "rightState")
                if let view = self.stackView.subviews[0].subviews.first as? UITextView {
                    let position = view.contentOffset
                    coder.encode(position, forKey: "leftOffset")
                }
                if let view = self.stackView.subviews[1].subviews.first as? UITextView {
                    let position = view.contentOffset
                    coder.encode(position, forKey: "rightOffset")
                }
                
                
            }
        }
        
        if let searchTerm = searchTerm {
            coder.encode(searchTerm, forKey: "searchTerm")
        }
        
        if let item = textItem {
            coder.encode(item.id, forKey: "id")
        }



        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        defer {super.decodeRestorableState(with: coder)}
        
        guard UIApplication.shared.delegate != nil else {return}
        guard let key = coder.decodeObject(forKey: "id") as? NSString else {return}
        guard let catalogueEntry = sqlite.texts.first(where: {$0.id == key as String}) else {return}
        guard let textStrings = sqlite.getTextStrings(key as String) else {return}
        
        self.textStrings = textStrings
        self.textItem = catalogueEntry

        
        switch coder.decodeBool(forKey: "isSingle") {
        case true:
            let rawDisplay = coder.decodeInteger(forKey: "leftState")
            let textDisplay = TextDisplay.init(rawValue: rawDisplay)!
            self.displayState = DisplayState.single(textDisplay)
            
            let offSet = coder.decodeCGPoint(forKey: "leftOffset")
            refreshState(leftOffSet: offSet, rightOffSet: nil)
            
        case false:
            let rawLeftDisplay = coder.decodeInteger(forKey: "leftState")
            let rawRightDisplay = coder.decodeInteger(forKey: "rightState")
            let leftDisplay = TextDisplay.init(rawValue: rawLeftDisplay)!
            let rightDisplay = TextDisplay.init(rawValue: rawRightDisplay)!
            self.displayState = DisplayState.double(left: leftDisplay, right: rightDisplay)
            
            let leftOffset = coder.decodeCGPoint(forKey: "leftOffset")
            let rightOffset = coder.decodeCGPoint(forKey: "rightOffset")
            refreshState(leftOffSet: leftOffset, rightOffSet: rightOffset)
        }
    }
    
    override func applicationFinishedRestoringState() {
        self.title = textItem?.title
    }
}


