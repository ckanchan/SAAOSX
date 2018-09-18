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
    /// Model for what the views are displaying
    enum DisplayState {
        case single(TextDisplay)
        case double(left: TextDisplay, right: TextDisplay)
    }

    @IBOutlet weak var primaryContainerView: UIView!
    @IBOutlet weak var secondaryContainerView: UIView!

    // MARK: - Instance Variables
    weak var parentController: ProjectListViewController?
    weak var catalogue: CatalogueProvider?
    var displayState: DisplayState?

    weak var primaryPanel: TextPanelViewController!
    weak var secondaryPanel: TextPanelViewController!

    var textItem: OraccCatalogEntry?
    var textStrings: TextEditionStringContainer? {
        didSet {
            textStrings?.render(withPreferences: ThemeController().themeFormatting)
        }
    }

    var searchTerm: String?
    lazy var darkMode: Bool = {
        return ThemeController().themePreference == .dark ?  true : false
    }()

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        initialiseToolbar()
        addInfoButton()
        registerThemeNotifications()

        primaryPanel = childViewControllers.first as? TextPanelViewController
        secondaryPanel = childViewControllers.last as? TextPanelViewController

        primaryPanel.delegate = self
        primaryPanel.textDisplay = .Normalisation

        secondaryPanel.delegate = self
        secondaryPanel.textDisplay = .Translation

        darkMode ? enableDarkMode() : disableDarkMode()
    }

    deinit {
        deregisterThemeNotifications()
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

    //TODO :- Refactor grotesquely horrible navigation.
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

            if traitCollection.horizontalSizeClass == .regular {
                if direction == .left {
                    parentController?.navigate(.left)
                } else {
                    parentController?.navigate(.right)
                }
            }
        }
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
        case .single:
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

    func string(for textKind: TextDisplay) -> NSAttributedString {
        let notAvailable = NSAttributedString(string: "Not available")
        let textColor = darkMode ? UIColor.lightText : UIColor.darkText

        switch textKind {
        case .Cuneiform:
            return NSAttributedString(string: (textStrings?.cuneiform ?? "Not available"), attributes: [NSAttributedStringKey.font: UIFont.cuneiformNA, .foregroundColor: textColor])
        case .Transliteration:
            return textStrings?.transliteration ?? notAvailable
        case .Normalisation:
            return textStrings?.normalisation ?? notAvailable
        case .Translation:
            return NSAttributedString(string: (textStrings?.translation ?? "Not available"), attributes: [NSAttributedStringKey.font: UIFont.defaultFont, .foregroundColor: textColor])

        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        switch traitCollection.horizontalSizeClass {
        case .regular:
            return

        default:
            return
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
}

extension TextEditionViewController: Themeable {
    func enableDarkMode() {
        view.backgroundColor = .black

        navigationController?.navigationBar.barStyle = .black
        navigationController?.toolbar.barStyle = .black
        primaryPanel.enableDarkMode()
        secondaryPanel.enableDarkMode()

        if let textItem = textItem {
            navigationItem.titleView = titleLabel(for: textItem, color: .lightText)
        }

        darkMode = true

    }

    func disableDarkMode() {
        view.backgroundColor = .white

        navigationController?.navigationBar.barStyle = .default
        navigationController?.toolbar.barStyle = .default
        primaryPanel.disableDarkMode()
        secondaryPanel.disableDarkMode()
        darkMode = false

        if let textItem = textItem {
            navigationItem.titleView = titleLabel(for: textItem, color: .darkText)
        }
    }
}

// MARK :- Factory methods for UI components
extension TextEditionViewController {
    func addInfoButton() {
        let info = UIButton(type: .infoLight)
        info.addTarget(self, action: #selector(presentInformation), for: UIControlEvents.touchUpInside)
        let infoBarButton = UIBarButtonItem(customView: info)
        navigationItem.rightBarButtonItem = infoBarButton
    }

    func makeNavigationButtons() -> (UIBarButtonItem, UIBarButtonItem) {
        let left = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(navigate(_:)))
        let right = UIBarButtonItem(title: ">", style: .plain, target: self, action: #selector(navigate(_:)))

        return (left, right)
    }

    func initialiseToolbar() {
        let quickDefine = UIBarButtonItem(title: "Quick define", style: .plain, target: parentController, action: #selector(ProjectListViewController.showGlossary(_:)))
        let (left, right) = makeNavigationButtons()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.setToolbarItems([quickDefine, spacer, left, right], animated: true)
    }

    func configureToolBar(withAttributedText text: NSAttributedString) {
        let newLabel = UILabel()
        
        if darkMode {
            let darkText: NSMutableAttributedString = NSMutableAttributedString(attributedString: text)
            darkText.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.orange], range: NSMakeRange(0, darkText.length))
            newLabel.attributedText = darkText
        } else {
            newLabel.attributedText = text
        }
        
        
        let newToolbarItem = UIBarButtonItem(customView: newLabel)
        toolbarItems![0] = newToolbarItem
    }
}

// MARK :- Restorable state methods
extension TextEditionViewController {

    override func encodeRestorableState(with coder: NSCoder) {
        if let displayState = displayState {
            switch displayState {
            case .single(let state):
                coder.encode(true, forKey: "isSingle")
                coder.encode(state.rawValue, forKey: "leftState")
                coder.encode(-1, forKey: "rightState")

            case .double(let left, let right):
                coder.encode(left.rawValue, forKey: "leftState")
                coder.encode(right.rawValue, forKey: "rightState")
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
        let textID = TextID.init(stringLiteral: key as String)
        guard let catalogueEntry = sqlite.texts.first(where: {$0.id == textID}) else {return}
        guard let textStrings = sqlite.getTextStrings(textID) else {return}

        self.textStrings = textStrings
        self.textItem = catalogueEntry

        switch coder.decodeBool(forKey: "isSingle") {
        case true:
            let rawDisplay = coder.decodeInteger(forKey: "leftState")
            let textDisplay = TextDisplay.init(rawValue: rawDisplay)!
            self.displayState = DisplayState.single(textDisplay)

        case false:
            let rawLeftDisplay = coder.decodeInteger(forKey: "leftState")
            let rawRightDisplay = coder.decodeInteger(forKey: "rightState")
            let leftDisplay = TextDisplay.init(rawValue: rawLeftDisplay)!
            let rightDisplay = TextDisplay.init(rawValue: rawRightDisplay)!
            self.displayState = DisplayState.double(left: leftDisplay, right: rightDisplay)
        }
    }

    override func applicationFinishedRestoringState() {
        self.title = textItem?.title
    }
}
