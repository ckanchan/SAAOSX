//
//  TextViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 17/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift

class TextViewController: NSViewController, NSTextViewDelegate {
    @IBOutlet weak var textSelected: NSSegmentedControl!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var definitionView: NSTextField!
    @IBOutlet var textMenu: NSMenu!

    @IBAction func setText(_ sender: Any) {
        guard let stringContainer = self.stringContainer else {return}
        switch self.textSelected.selectedSegment {
        case 0:
            textView.string = stringContainer.cuneiform
            textView.font = NSFont(name: "CuneiformNAOutline-Medium", size: NSFont.systemFontSize)
        case 1:
            textView.textStorage?.setAttributedString(stringContainer.transliteration)
        case 2:
            textView.textStorage?.setAttributedString(stringContainer.normalisation)
        case 3:
            textView.string = stringContainer.translation
            textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        default:
            return
        }
    }
    
    
    var textEdition: OraccTextEdition? {
        didSet {
            stringContainer = TextEditionStringContainer(self.textEdition!)
        }
    }
    var catalogueEntry: OraccCatalogEntry?
    var stringContainer: TextEditionStringContainer?
    
    lazy var cuneiform: String = {
        return self.textEdition?.cuneiform ?? "No edition availabe"
    }()
    
    lazy var transliteration: NSAttributedString = {
        return self.textEdition?.formattedTransliteration(withFont: NSFont.systemFont(ofSize: NSFont.systemFontSize)) ?? NSAttributedString(string: "No edition available")
    }()
    
    lazy var normalisation: NSAttributedString = {
        return self.textEdition?.formattedNormalisation(withFont: NSFont.systemFont(ofSize: NSFont.systemFontSize)) ?? NSAttributedString(string: "No edition available")
    }()
    
    lazy var translation: String = {
       return self.textEdition?.scrapeTranslation ?? self.textEdition?.literalTranslation ?? "No translation available"
    }()
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.title = catalogueEntry?.title ?? "Text Edition"
        setText(self)
        textView.delegate = self
    }
    
    
    
    // MARK :- Toolbar Control Methods
    @IBAction func newTextWindow(_ sender: Any) {
        guard let newWindow = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("textWindow")) as? NSWindowController else {return}
        guard let newView = newWindow.contentViewController as? TextViewController else {return}
        
        newView.catalogueEntry = self.catalogueEntry
        newView.textEdition = self.textEdition
        newWindow.window?.title = "\(catalogueEntry!.displayName): \(catalogueEntry!.title)"
        
        newWindow.showWindow(nil)
        
    }
    
    @IBAction func showInfoView(_ sender: Any) {
        guard let infoWindow = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("infoWindow")) as? NSWindowController else {return}
        guard let infoView = infoWindow.contentViewController as? InfoViewController else {return}
        
        infoView.infoLabel.stringValue = self.catalogueEntry?.description ?? "?"
        infoWindow.showWindow(nil)
    }
    
    @IBAction func newDocument(_ sender: Any){
        newTextWindow(self)
    }
    
    
    func textView(_ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
        let menu = NSMenu(title: "Text")
        let str = view.attributedString()
        let words = str.attributes(at: charIndex, effectiveRange: nil)
        
        if let citationForm = words[.oraccCitationForm] as? String {
            menu.addItem(withTitle: citationForm, action: nil, keyEquivalent: "")
        }
        
        if let guideWord = words[.oraccGuideWord] as? String {
            menu.addItem(withTitle: guideWord, action: nil, keyEquivalent: "")
        }

        if let sense = words[.oraccSense] as? String {
            menu.addItem(withTitle: sense, action: nil, keyEquivalent: "")
        }
        
        guard menu.items.count > 0 else { return nil }
        
        return menu
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
            let guideWord = attrs[NSAttributedStringKey.oraccGuideWord] as? String
            definitionView.stringValue = guideWord ?? ""
            
            
        default:
            return
        }
    }
    
    @IBAction func viewOnline(_ sender: Any) {
        if let text = catalogueEntry {
            var baseURL = URL(string: "http://oracc.org")!
            baseURL.appendPathComponent(text.project)
            baseURL.appendPathComponent(text.id)
            baseURL.appendPathComponent("html")
            NSWorkspace.shared.open(baseURL)
        }
    }
    
    @IBAction func navigate(_ sender: NSSegmentedControl){
        switch sender.selectedSegment {
        case 0:
            print("navigate back")
        case 1:
             print("navigate forward")
        default:
            return
        }
    }
    
    @IBAction func glossary(_ sender: Any){
        guard catalogueEntry != nil else {return}
        
        var glossary: OraccGlossary?
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            glossary = try? self.oracc.loadGlossary(.neoAssyrian, catalogueEntry: self.catalogueEntry!)
            
            DispatchQueue.main.async {
                if let glossary = glossary {
                    guard let glossaryWindow = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("GlossaryWindow")) as? GlossaryWindowController else {return}
                    guard let splitViewController = glossaryWindow.contentViewController as? GlossarySplitViewController else {return}
                    
                    splitViewController.searchField = glossaryWindow.searchField
                    guard let glossaryListViewController = splitViewController.childViewControllers.first as? GlossaryListViewController else {return}
                    
                    glossaryListViewController.glossaryEntries = glossary.entries
                    glossaryListViewController.definitionViewController = splitViewController.childViewControllers.last as? GlossaryEntryViewController
                    glossaryWindow.showWindow(nil)
                }
            }
        }
    }
    
}

