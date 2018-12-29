//
//  TextViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 17/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc

class TextViewController: NSViewController, NSTextViewDelegate, TextNoteDisplaying {

    public enum Navigate {
        case left, right
    }

    @IBOutlet weak var textSelected: NSSegmentedControl!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var definitionView: NSTextField!
    @IBOutlet var textMenu: NSMenu!

    var searchTerm: String?
    var catalogue: CatalogueProvider?
    var stringContainer: TextEditionStringContainer?
    var splitViewController: NSSplitViewController?
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
        return catalogue?.texts.index(where: {$0.id == self.catalogueEntry.id})
        }()

    lazy var windowController = {return self.view.window?.windowController as? TextWindowController}()

    lazy var fontManager = {return NSFontManager.shared}()
    
    lazy var notesManager: FirebaseTextNoteManager? = {
        return getNotesManager()
        }()
    
    func getNotesManager() -> FirebaseTextNoteManager? {
        guard let user = self.user.user else {return nil}
        return FirebaseTextNoteManager(for: user, textID: catalogueEntry.id, delegate: self)
    }
    
    var note: Note? {
        didSet {
            if note != nil {
                highlightAnnotations(in: self.textView)
            }
        }
    }
    
    func noteDidChange(_ note: Note) {
        self.note = note
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.title = catalogueEntry?.title ?? "Text Edition"
        setText(self)
        textView.delegate = self

        self.textView.usesFontPanel = true
        if let listener = self.notesManager?.listener {
            print("Initialised listener, handle \(listener)")
        } else {
            print("Some listener error occured")
        }
    }
    
    override func viewWillDisappear() {
        self.notesManager = nil
    }
    
    
    func highlightAnnotations(in textView: NSTextView) {
        guard let note = self.note else {return}
        let annotations = note.annotations.keys.description
        textView.textStorage?.enumerateAttribute(.reference, in: NSRange(location: 0, length: textView.textStorage!.length), options: .longestEffectiveRangeNotRequired, using: {
            value, range, _ in
            guard let stringVal = value as? String else {return}
            if annotations.contains(stringVal) {
                guard range.length > 2 else {return}
                let newRange = NSRange(location: range.location, length: range.length - 1)
                textView.textStorage?.addAttributes(
                    [NSAttributedString.Key.backgroundColor: NSColor.systemPink,
                     NSAttributedString.Key.toolTip: note.annotations[NodeReference(stringLiteral: stringVal)]?.annotation ?? ""
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
            fontManager.setSelectedFont(cuneiformNA, isMultiple: false)
        case 1:
            textView.textStorage?.setAttributedString(stringContainer.transliteration)
        case 2:
            textView.textStorage?.setAttributedString(stringContainer.normalisation)
            highlightAnnotations(in: textView)
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

    @IBAction func changeFont(_ sender: Any?) {
        guard let sender = sender as? NSFontManager else {return}
        let newFont: NSFont
        if let oldFont = self.textView.font {
            newFont = sender.convert(oldFont)
        } else {
            newFont = sender.selectedFont ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
        }

        //self.stringContainer?.render(withPreferences: newFont.makeDefaultPreferences())
        self.textView.setFont(newFont, range: NSRange(location: 0, length: self.textView.string.utf16.count))
    }

    // MARK :- Toolbar Control Methods
    @IBAction func newTextWindow(_ sender: Any) {
        TextWindowController.new(self.catalogueEntry, strings: self.stringContainer, catalogue: self.catalogue)
    }

    @IBAction func showInfoView(_ sender: Any) {
        guard let infoWindow = storyboard?.instantiateController(withIdentifier: "infoWindow") as? NSWindowController else {return}
        guard let infoView = infoWindow.contentViewController as? InfoViewController else {return}

        infoView.textId = self.catalogueEntry.id
        infoView.infoLabel.stringValue = self.catalogueEntry.description
        
        infoWindow.showWindow(nil)
    }

    @IBAction func newDocument(_ sender: Any) {
        newTextWindow(self)
    }

    func loadText(entry: OraccCatalogEntry) -> Bool {
        if let text = sqlite?.getTextStrings(entry.id) {
            catalogueEntry = entry
            notesManager = getNotesManager()
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
        
        
        let annotationItem = NSMenuItem(title: "Add annotation", action: #selector(newAnnotationWindow), keyEquivalent: "")
        
        let annotatedTitle = NSAttributedString(string: "Add annotation",
                                                        attributes: menuMetadata)
        
        annotationItem.attributedTitle = annotatedTitle
        
        menu.addItem(annotationItem)
        
        return menu
    }

    @objc func lookUpInGlossaryWindow(_ sender: NSMenuItem) {
        GlossaryWindowController.searchField(sender)
    }
    
    @objc func newAnnotationWindow(_ sender: NSMenuItem) {
        guard let metadata = sender.attributedTitle?.attributes(at: 0, effectiveRange: nil) else {return}
        
        guard let citationForm = metadata[.oraccCitationForm] as? String,
            let transliteration = metadata[.writtenForm] as? String,
            let translation = metadata[.instanceTranslation] as? String,
            let context = metadata[.referenceContext] as? String,
            let reference = metadata[.reference] as? String else {return}
        
        let nodeReference = NodeReference.init(stringLiteral: reference)
        guard let window = AnnotationPopupController.new(textID: catalogueEntry.id, node: nodeReference, user: user, transliteration: transliteration, normalisation: citationForm, translation: translation, context: context) else {return}
        
        window.showWindow(self)
        guard let annotationVc = window.contentViewController as? AnnotationPopupController else {return}
        annotationVc.textField.becomeFirstResponder()
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        fontManager.target = self
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

    @IBAction func viewOnline(_ sender: Any) {
        var baseURL = URL(string: "http://oracc.org")!
        baseURL.appendPathComponent(catalogueEntry.project)
        baseURL.appendPathComponent(catalogueEntry.id.description)
        baseURL.appendPathComponent("html")
        NSWorkspace.shared.open(baseURL)
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
        return
    }
}
