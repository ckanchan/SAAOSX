//
//  DetailViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 06/03/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import CDKSwiftOracc

enum TextDisplay: Int {
    case Cuneiform = 0, Transliteration, Normalisation, Translation
}

class TextEditionViewController: UIViewController {
    var stackView: UIStackView!
    
    // MARK: - Instance Variables
    weak var parentController: ProjectListViewController?
    weak var catalogue: CatalogueProvider?


    var primaryPanel: TextPanelViewController!
    var secondaryPanel: TextPanelViewController?

    var textItem: OraccCatalogEntry? {
        didSet {
            guard let textItem = self.textItem else {return}
            navigationItem.titleView = titleLabel(for: textItem, color: .darkText)
        }
    }
    
    var textStrings: TextEditionStringContainer? {
        didSet {
            textStrings?.render(withPreferences: UIFont.systemFont(ofSize: UIFont.systemFontSize).makeDefaultPreferences())
            refreshPanels()
        }
    }

    var searchTerm: String?

    override func loadView() {
        let stackView = UIStackView(frame: .zero)
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        self.view = stackView
        self.stackView = stackView
    }
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        initialiseToolbar()
        addInfoButton()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch traitCollection.horizontalSizeClass {
        case .compact:
            addPrimaryPanel()
            
        case .regular:
            addPrimaryPanel()
            addSecondaryPanel()
            
        case .unspecified:
            addPrimaryPanel()

        @unknown default:
            addPrimaryPanel()
        }
    }
    
    func addPrimaryPanel() {
        guard self.primaryPanel == nil else {return}
        primaryPanel = TextPanelViewController.new(delegate: self, textDisplay: .Normalisation)
        self.addChild(primaryPanel)
        primaryPanel.loadViewIfNeeded()
        stackView.addArrangedSubview(primaryPanel.view)
        primaryPanel.didMove(toParent: self)
    }
    
    func addSecondaryPanel() {
        guard self.secondaryPanel == nil else {return}
        secondaryPanel = TextPanelViewController.new(delegate: self, textDisplay: .Translation)
        self.addChild(secondaryPanel!)
        secondaryPanel!.loadViewIfNeeded()
        stackView.addArrangedSubview(secondaryPanel!.view)
        secondaryPanel?.didMove(toParent: self)
    }
    
    func removeSecondaryPanelIfExists() {
        guard let secondaryPanel = self.secondaryPanel else {return}
        secondaryPanel.willMove(toParent: nil)
        stackView.removeArrangedSubview(secondaryPanel.view)
        secondaryPanel.removeFromParent()
        self.secondaryPanel = nil
    }

    
    func titleLabel(for item: OraccCatalogEntry, color: UIColor) -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = color
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        label.textAlignment = .center
        label.text = "\(item.title)\n\(item.displayName)"
        label.minimumScaleFactor = CGFloat.init(0.25)
        label.allowsDefaultTighteningForTruncation = true

        return label
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    func refreshPanels() {
        self.primaryPanel?.changeText(display: .Normalisation, scrollToTop: true)
        self.secondaryPanel?.changeText(display: .Translation, scrollToTop: true)
    }


    //TODO :- Refactor grotesquely horrible navigation.
    @objc func navigate(_ sender: Any) {
        guard let catalogue = self.catalogue,
            let id = self.textItem?.id,
            let currentRow = catalogue.texts.firstIndex(where: {$0.id == id}) else {return}
        
        let nextRow: Int
        var direction: Navigate
        
        if let button = sender as? UIBarButtonItem {
            switch button.title {
            case .some("<"):
                direction = .left
            case .some(">"):
                direction = .right
            default:
                return
            }
        } else if let keyCommand = sender as? UIKeyCommand {
            switch keyCommand.input {
            case UIKeyCommand.inputLeftArrow:
                direction = .left
            case UIKeyCommand.inputRightArrow:
                direction = .right
            default:
                return
            }
        } else {
            return
        }
        
        switch direction {
        case .left:
            nextRow = currentRow - 1
            guard nextRow >= catalogue.texts.startIndex else {return}
        case .right:
            nextRow = currentRow + 1
            guard nextRow < catalogue.texts.endIndex else {return}
        }
        
        guard let nextEntry = catalogue.text(at: nextRow),
            let strings = sqlite.getTextStrings(nextEntry.id) else {return}
        
        self.textStrings = strings
        self.textItem = nextEntry
        self.title = nextEntry.title
        self.primaryPanel?.changeText(display: .Normalisation, scrollToTop: true)
        self.secondaryPanel?.changeText(display: .Translation, scrollToTop: true)
        
        if traitCollection.horizontalSizeClass == .regular {
            parentController?.navigate(direction)
        }
    }


    #warning("Text rendering is inconsistent")
    func string(for textKind: TextDisplay) -> NSAttributedString {
        let notAvailable = NSAttributedString(string: "Not available")

        switch textKind {
        case .Cuneiform:
            return NSAttributedString(string: (textStrings?.cuneiform ?? "Not available"), attributes: [NSAttributedString.Key.font: UIFont.cuneiformNA])
        case .Transliteration:
            return textStrings?.transliteration ?? notAvailable
        case .Normalisation:
            return textStrings?.normalisation ?? notAvailable
        case .Translation:
            return NSAttributedString(string: (textStrings?.translation ?? "Not available"), attributes: [NSAttributedString.Key.font: UIFont.defaultFont])

        }
    }
}

// MARK: - Outbound Methods
extension TextEditionViewController {
    func viewOnline() {
        guard let catalogueInfo = self.textItem else {return}
        let textID = catalogueInfo.id
        let projectPath = catalogueInfo.project
        let url = URL(string: "http://oracc.org/\(projectPath)/\(textID)/html")!

        let webView = OnlineViewController()
        webView.url = url

        self.navigationController?.pushViewController(webView, animated: true)
    }

    @objc func presentInformation() {
        guard let catalogueInfo = self.textItem else {return}
        let storyboard = UIStoryboard(name: "TextEdition", bundle: nil)
        guard let infoTableController = storyboard.instantiateViewController(withIdentifier: StoryboardIDs.InfoTableViewController) as? InfoTableViewController else {return}
        infoTableController.catalogueInfo = catalogueInfo
        infoTableController.textEditionViewController = self
        infoTableController.tableView.delegate = infoTableController

        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            infoTableController.modalPresentationStyle = .popover
            present(infoTableController, animated: true)
            let popoverController = infoTableController.popoverPresentationController
            popoverController?.barButtonItem = self.navigationItem.rightBarButtonItem
        } else {
            navigationController?.pushViewController(infoTableController, animated: true)
        }
    }
}

// MARK :- Factory methods for UI components
extension TextEditionViewController {
    func addInfoButton() {
        let info = UIButton(type: .infoLight)
        info.addTarget(self, action: #selector(presentInformation), for: UIControl.Event.touchUpInside)
        let infoBarButton = UIBarButtonItem(customView: info)
        navigationItem.rightBarButtonItem = infoBarButton
    }

    func makeNavigationButtons() -> (UIBarButtonItem, UIBarButtonItem) {
        let left = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(navigate(_:)))
        let right = UIBarButtonItem(title: ">", style: .plain, target: self, action: #selector(navigate(_:)))

        return (left, right)
    }

    func initialiseToolbar() {
        #warning("Readd a quick define action to look up the word in glossary")
        let quickDefine = UIBarButtonItem(title: "Quick define", style: .plain, target: nil, action: nil)
        let (left, right) = makeNavigationButtons()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.setToolbarItems([quickDefine, spacer, left, right], animated: true)
    }

    func configureToolBar(withAttributedText text: NSAttributedString) {
        let newLabel = UILabel()
        newLabel.attributedText = text
        let newToolbarItem = UIBarButtonItem(customView: newLabel)
        toolbarItems![0] = newToolbarItem
    }
}
