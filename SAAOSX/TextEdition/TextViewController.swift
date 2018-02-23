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
    
    var catalogueController: CatalogueProvider?
    
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
        case 3:
            textView.string = stringContainer.translation
            textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        default:
            return
        }
    }
    
    @IBAction override func changeFont(_ sender: Any?) {
        guard let sender = sender as? NSFontManager else {return}
        let newFont: NSFont
        if let oldFont = self.textView.font {
            newFont = sender.convert(oldFont)
        } else {
            newFont = sender.selectedFont ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
        }
        self.textView.setFont(newFont, range: NSMakeRange(0, self.textView.string.utf16.count))
    }
    
    
    var splitViewController: NSSplitViewController?
    
    var catalogueEntry: OraccCatalogEntry? {
        didSet{
            guard splitViewController == nil else {return}
            guard self.windowController != nil else {return}
            windowController?.catalogueSearch.stringValue = catalogueEntry?.title ?? ""
        }
    }
    
    var stringContainer: TextEditionStringContainer?
    lazy var windowController = {return self.view.window?.windowController as? TextWindowController}()
    
    
    lazy var fontManager = {return NSFontManager.shared}()
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.title = catalogueEntry?.title ?? "Text Edition"
        setText(self)
        textView.delegate = self
        
        self.textView.usesFontPanel = true
    }

    // MARK :- Toolbar Control Methods
    @IBAction func newTextWindow(_ sender: Any) {
        guard let newWindow = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("textWindow")) as? TextWindowController else {return}
        guard let newView = newWindow.contentViewController as? TextViewController else {return}
        
        
        newView.catalogueController = self.catalogueController
        newView.catalogueEntry = self.catalogueEntry
        newView.stringContainer = self.stringContainer
        newWindow.window?.title = "\(catalogueEntry!.displayName): \(catalogueEntry!.title)"
        newWindow.textViewController = [newView]
        
        newWindow.showWindow(self)
        
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
        fontManager.target = self
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
        GlossaryWindowController.new(self)
    }
    
    @IBAction func saveEncode(_ sender: Any) {
        
        guard let cat = self.catalogueEntry else {return}
        guard let str = self.stringContainer else {return}
        
        do {
            try pinnedTextController.save(entry: cat, strings: str)
        } catch {
            print(error)
        }
        
        
        
        
        
//        let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(self.catalogueEntry!.id).appendingPathExtension("oraccstringcontainer")
//
//
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//
//        do {
//            let data = try encoder.encode(self.stringContainer!)
//            try data.write(to: path)
//        } catch {print(error)}

        
        
    }
}

