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
    
    var textStrings: TextEditionStringContainer? {
        didSet {
            textStrings?.render(withPreferences: TextEditionViewController.defaultFormattingPreferences)
        }
    }
    
    enum TextDisplay {
        case Cuneiform, Transliteration, Normalisation, Translation
    }
    
    enum DisplayState {
        case single(TextDisplay)
        case double(left: TextDisplay, right: TextDisplay)
    }
    
    var displayState: DisplayState? = nil
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
        
        infoTableController.modalPresentationStyle = .popover
        present(infoTableController, animated: true)
        let popoverController = infoTableController.popoverPresentationController
        popoverController?.barButtonItem = self.navigationItem.rightBarButtonItem
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
        configureToolBar(withText: "Quick define")
        addInfoButton()
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
            setState(isSingleColumn: true)
            
            
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
            
            setState(isSingleColumn: false)
            
            
            stackView.distribution = .fillEqually
        }
    }
    
    func setState(isSingleColumn: Bool) {
        if isSingleColumn {
            self.displayState = DisplayState.single(.Transliteration)
        } else {
            self.displayState = DisplayState.double(left: .Transliteration,
                                                    right: .Translation)
        }
    }
    
    
    func configureToolBar(withText text: String) {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        
        let toolbarItem = UIBarButtonItem(customView: label)
        self.setToolbarItems([toolbarItem], animated: true)
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
            guard let textView = self.stackView.subviews[0].subviews.first as? UITextView else {return}
            switchTextTo(newState, textView: textView)
            self.displayState = DisplayState.single(newState)
            
        case .double(let leftDisplay, let rightDisplay):
            let textViewToChange: UITextView
            let newDisplayState: DisplayState
            
            switch sender.tag {
            case 0: // Changing the left display's text
                guard let textView = self.stackView.subviews[0].subviews.first as? UITextView else {return}
                textViewToChange = textView
                newDisplayState = DisplayState.double(left: newState, right: rightDisplay)
                
            case 1: // Changing the right display's text
                guard let textView = self.stackView.subviews[1].subviews.first as? UITextView else {return}
                textViewToChange = textView
                newDisplayState = DisplayState.double(left: leftDisplay, right: newState)
                
            default: // Big error
                return
            }
            
            switchTextTo(newState, textView: textViewToChange)
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
}

