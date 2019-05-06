//
//  TextViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 17/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc

class TextViewController: NSViewController, NSTextViewDelegate {

    public enum Navigate {
        case left, right
    }

    @IBOutlet weak var textSelected: NSSegmentedControl!
    @IBOutlet weak var textView: NSTextView!
    @IBOutlet weak var definitionView: NSTextField!
    @IBOutlet weak var textMenu: NSMenu!

    var searchTerm: String?
    var catalogue: CatalogueProvider?
    var stringContainer: TextEditionStringContainer?
    weak var splitViewController: NSSplitViewController?
    var catalogueEntry: OraccCatalogEntry! {
        didSet {
            guard let cat = catalogueEntry else {return}
            self.saved = self.bookmarks.contains(textID: cat.id.description)

            guard self.windowController != nil else {return}
            guard splitViewController == nil else {return}
            windowController?.catalogueSearch.stringValue = catalogueEntry.title
        }
    }
    var saved: Bool? = false {
        didSet {
            guard self.windowController != nil else {return}
            if case .some(true) = self.saved {
                windowController?.bookmarksBtn.state = .on
            } else {
                windowController?.bookmarksBtn.state = .off
            }
        }
    }
    
    lazy var currentIdx: Int? = {
        return catalogue?.texts.firstIndex(where: {$0.id == self.catalogueEntry.id})
        }()

    var windowController: TextWindowController?
    

    override func viewWillAppear() {
        super.viewWillAppear()
        self.title = catalogueEntry?.title ?? "Text Edition"
        setText(self)
        textView.delegate = self
        annotationsWereUpdated()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        guard let windowController = self.windowController else {return}
        windowController.textViewController.removeAll()
        self.windowController = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(annotationsDidChange),
                                               name: .annotationsChangedForText,
                                               object: nil)
    }
    
    @objc func annotationsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: TextID],
            catalogueEntry.id == userInfo["textID"] else {return}
        
        annotationsWereUpdated()
    }
    
    func highlightAnnotations(in textView: NSTextView, annotations: [String: Annotation]) {
        textView.textStorage?.enumerateAttribute(.reference, in: NSRange(location: 0, length: textView.textStorage!.length), options: .longestEffectiveRangeNotRequired, using: {
            value, range, _ in
            guard let stringVal = value as? String else {return}
            let fullPath = String(catalogueEntry.id) + "." + stringVal
            if let annotation = annotations[fullPath] {
                guard range.length > 2 else {return}
                let newRange = NSRange(location: range.location, length: range.length - 1)
                textView.textStorage?.addAttributes(
                    [NSAttributedString.Key.backgroundColor: NSColor.systemPink,
                     NSAttributedString.Key.toolTip: annotation.annotation
                    ],
                    range: newRange)
            }
        })
    }
    
    func highlightSearchTerm(_ searchTerm: String, in textView: NSTextView) {
        textView.textStorage?.enumerateAttribute(.oraccCitationForm, in: NSRange(location: 0, length: textView.textStorage!.length), options: .longestEffectiveRangeNotRequired, using: {
            value, range, _ in
            guard let stringVal = value as? String else {return}
            if searchTerm.lowercased() == stringVal.lowercased() {
                guard range.length > 2 else {return}
                let newRange = NSRange(location: range.location, length: range.length - 1)
                textView.textStorage?.addAttributes([NSAttributedString.Key.backgroundColor: NSColor.systemYellow], range: newRange)
            }
        })
    }
    
    @IBAction func setText(_ sender: Any) {
        guard let stringContainer = self.stringContainer else {return}
        switch self.textSelected.selectedSegment {
        case 0:
            let cuneiformNA = NSFont(name: "CuneiformNAOutline-Medium", size: NSFont.systemFontSize) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            textView.string = stringContainer.cuneiform
            textView.font = cuneiformNA
        case 1:
            textView.textStorage?.setAttributedString(stringContainer.transliteration)
        case 2:
            textView.textStorage?.setAttributedString(stringContainer.normalisation)
            annotationsWereUpdated()
            if let searchTerm = searchTerm {
                highlightSearchTerm(searchTerm, in: textView)
            }
            
        case 3:
            textView.string = stringContainer.translation
            textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        default:
            return
        }
    }


    // MARK :- Toolbar Control Methods
    @IBAction func newTextWindow(_ sender: Any) {
        TextWindowController.new(self.catalogueEntry, strings: self.stringContainer, catalogue: self.catalogue)
    }

    @IBAction func showInfoView(_ sender: Any) {
        guard let infoWindow = storyboard?.instantiateController(withIdentifier: "infoWindow") as? NSWindowController else {return}
        guard let infoView = infoWindow.contentViewController as? InfoViewController else {return}

        infoView.textID = self.catalogueEntry.id
        infoView.infoLabel.stringValue = self.catalogueEntry.description
        
        infoWindow.showWindow(nil)
    }

    @IBAction func newDocument(_ sender: Any) {
        newTextWindow(self)
    }

    func loadText(entry: OraccCatalogEntry) -> Bool {
        if let text = sqlite?.getTextStrings(entry.id) {
            catalogueEntry = entry
            text.render(withPreferences: TextWindowController.defaultformattingPreferences)
            stringContainer = text
            
            setText(self)
            windowController?.window?.title = "\(entry.displayName): \(entry.title)"
            windowController?.catalogueSearch.stringValue = entry.title
            return true
        } else {
            if let text = try? self.oracc.loadText(entry) {
                let stringContainer = TextEditionStringContainer(text)
                stringContainer.render(withPreferences: TextWindowController.defaultformattingPreferences)
                self.catalogueEntry = entry
                self.stringContainer = stringContainer
                self.setText(self)
                self.windowController?.window?.title = "\(entry.displayName): \(entry.title)"
                return true
            }
        }

        return false
    }

    func textView(_ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
        let menu = NSMenu(title: "Text")
        let str = view.attributedString()
        let metadata = str.attributes(at: charIndex, effectiveRange: nil)
        guard let citationForm = metadata[.oraccCitationForm] as? String,
            let transliteration = metadata[.writtenForm] as? String,
            let reference = metadata[.reference] as? String,
            let translation = metadata[.instanceTranslation] as? String else {return nil}
        
        menu.addItem(withTitle: citationForm, action: #selector(lookUpInGlossaryWindow), keyEquivalent: "")
        menu.addItem(withTitle: transliteration, action: nil, keyEquivalent: "")
        menu.addItem(withTitle: translation, action: nil, keyEquivalent: "")

        let contextRange = view.selectionRange(forProposedRange: NSMakeRange(charIndex, 0), granularity: .selectByParagraph)
        let contextStr = str.attributedSubstring(from: contextRange).string
        
        let menuMetadata: [NSAttributedString.Key: String] = [.oraccCitationForm: citationForm,
                                                             .writtenForm: transliteration,
                                                             .instanceTranslation: translation,
                                                             .reference: reference,
                                                             .referenceContext: contextStr]
        
        let annotationLabel: String
        
        if let highlight = metadata[.backgroundColor] as? NSColor,
            highlight == .systemPink {
            annotationLabel = "Edit annotation"
        } else {
            annotationLabel = "Add annotation"
        }
        
        let annotationItem = NSMenuItem(title: annotationLabel, action: #selector(newAnnotationWindow), keyEquivalent: "")
        let annotatedTitle = NSAttributedString(string: annotationLabel,
                                                        attributes: menuMetadata)
        
        annotationItem.attributedTitle = annotatedTitle
        
        menu.addItem(annotationItem)
        
        return menu
    }

    @objc func lookUpInGlossaryWindow(_ sender: NSMenuItem) {
        GlossaryWindowController.searchField(sender)
    }
    
    @objc func newAnnotationWindow(_ sender: NSMenuItem) {
        let window: NSWindowController?
        guard let metadata = sender.attributedTitle?.attributes(at: 0, effectiveRange: nil) else {return}
        guard let reference = metadata[.reference] as? String else {return}
        let userTags = notesDB.tagSet ?? UserTags([])
        
        #warning("this code needs  to differentiate between short and long nodereferences encoded in the nsattrubutedstring")
        let nodeReference = NodeReference(base: catalogueEntry.id,
                                          path: reference.split(separator: ".").map({String($0)}))
        
        if let annotation = notesDB.retrieveSingleAnnotation(nodeReference) {
            window = AnnotationPopupController.new(withAnnotation: annotation, userTags: userTags)
        } else {
            guard let citationForm = metadata[.oraccCitationForm] as? String,
                let transliteration = metadata[.writtenForm] as? String,
                let translation = metadata[.instanceTranslation] as? String,
                let context = metadata[.referenceContext] as? String,
                let reference = metadata[.reference] as? String else {return}
            
            let nodeReference = NodeReference(base: catalogueEntry.id, path: reference.split(separator: ".").map { String($0)})
            window = AnnotationPopupController.new(textID: catalogueEntry.id,
                                                   node: nodeReference,
                                                   transliteration: transliteration,
                                                   normalisation: citationForm,
                                                   translation: translation,
                                                   context: context,
                                                   userTags: userTags)
        }
        window?.showWindow(self)
        guard let annotationVc = window?.contentViewController as? AnnotationPopupController else {return}
        annotationVc.textField.becomeFirstResponder()
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        switch self.textSelected.selectedSegment {
        case 2:
            //transliteration

            guard textView.selectedRanges.first != nil else {return}
            let range = textView.selectedRanges.first! as! _NSRange
            if range.length == 0 {return}

            guard let selectedText = textView.textStorage?.attributedSubstring(from: range) else {return}

            let attrs = selectedText.attributes(at: 0, effectiveRange: nil)
            let guideWord = attrs[NSAttributedString.Key.oraccGuideWord] as? String
            definitionView.stringValue = guideWord ?? ""

        default:
            return
        }
    }

    @IBAction func navigate(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            navigate(.left)
        case 1:
            navigate(.right)
        default:
            return
        }
    }

    func navigate(_ direction: Navigate) {
        guard let currentIdx = self.currentIdx else {return}
        guard let catalogueController = self.catalogue else {return}

        switch direction {
        case .left:
            let prev = currentIdx - 1
            guard prev >= 0 else {return}
            guard catalogueController.texts.count >= prev else {return}
            let newCatalogueEntry = catalogueController.texts[prev]
            if loadText(entry: newCatalogueEntry) {
                self.currentIdx = prev
            }
        case .right:
            let next = currentIdx + 1
            guard catalogueController.texts.count > next else {return}
            let newCatalogueEntry = catalogueController.texts[next]
            if loadText(entry: newCatalogueEntry) {
                self.currentIdx = next
            }
        }
    }
}

// Toolbar control methods live here
extension TextViewController {
    
    @IBAction func viewOnline(_ sender: Any) {
        var baseURL = URL(string: "http://oracc.org")!
        baseURL.appendPathComponent(catalogueEntry.project)
        baseURL.appendPathComponent(catalogueEntry.id.description)
        baseURL.appendPathComponent("html")
        NSWorkspace.shared.open(baseURL)
    }
    @IBAction func glossary(_ sender: Any) {
        GlossaryWindowController.new(self)
    }
    
    @IBAction func bookmark(_ sender: NSButton) {
        guard let str = self.stringContainer else {return}
        
        if let alreadySaved = self.bookmarks.contains(textID: self.catalogueEntry.id.description) {
            if alreadySaved {
                self.bookmarks.remove(entry: self.catalogueEntry)
                sender.state = .off
            } else {
                do {
                    try bookmarks.save(entry: self.catalogueEntry, strings: str)
                    sender.state = .on
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func showMapView(_ sender: NSButton) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let placeNames = self?.stringContainer?.getLocationNamesInText() else {return}
            
            guard let url = Bundle.main.url(forResource: "qpn_pleiades", withExtension: "json") else {return}
            guard let locationDictionary = AncientLocation.getListOfPlaces(from: url) else {return}
            
            var placesDictionary = [String: AncientLocation]()
            placeNames.forEach {name in
                guard let place = locationDictionary.first(where: {(_, location) in
                    guard let title = location.title else {return false}
                    return title == name
                }) else {return}
                
                placesDictionary[place.key] = place.value
            }
            
            if let pleiadesID = self?.catalogueEntry.pleiadesID,
                let record = PleiadesRecord.lookupInPleiades(id: pleiadesID),
                let (longitude, latitude) = record.representativePoint {
                let letterExcavationSite = AncientLocation(latitude: latitude, longitude: longitude, title: record.title, subtitle: record.description)
                placesDictionary["excavationSite"] = letterExcavationSite
                
            }
            
            let ancientMap = AncientMap(locationDictionary: placesDictionary)
            DispatchQueue.main.async {
                MapViewController.new(forMap: ancientMap)
            }
        }
    }
}
extension TextViewController {
    func annotationsWereUpdated() {
        let annotations = notesDB.retrieveAnnotations(forID: catalogueEntry.id)
        var strAnnotations = [String: Annotation]()
        annotations.forEach{
            strAnnotations[String($0.nodeReference)] = $0
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let vc = self else {return}
            vc.highlightAnnotations(in: vc.textView, annotations: strAnnotations)
        }
    }
}
