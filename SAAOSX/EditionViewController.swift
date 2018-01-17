//
//  EditionViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 14/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift

class EditionViewController: NSViewController, NSTabViewDelegate {
    

    
    var cuneiform: String? {
        didSet {
            if let cuneiform = self.cuneiform {
                cuneiformDocumentView.string = cuneiform
                cuneiformTextView.string = cuneiform
            }
        }
    }
    var transliteration: NSAttributedString? {
        didSet {
            if let transliteration = self.transliteration {
                transliterationDocumentView.textStorage?.setAttributedString(transliteration)
                cuneiformTextView.textStorage?.setAttributedString(transliteration)
            }
        }
    }
    var normalisation: NSAttributedString? {
        didSet {
            if let normalisation = normalisation {
                normalisationDocumentView.textStorage?.setAttributedString(normalisation)
                transcriptionTextView.textStorage?.setAttributedString(normalisation)
            }
        }
    }
    var translation: String? {
        didSet {
            if let translation = translation {
                translationDocumentView.string = translation
                translationTextView.string = translation
            }
        }
    }

    //Hackish until i figure out how to make this tab view work
    @IBOutlet weak var cuneiformView: NSScrollView!
    @IBOutlet weak var transliterationView: NSScrollView!
    @IBOutlet weak var normalisationView: NSScrollView!
    @IBOutlet weak var translationView: NSScrollView!
    @IBOutlet var cuneiformTextView: NSTextView!
    @IBOutlet var transliterationTextView: NSTextView!
    @IBOutlet var transcriptionTextView: NSTextView!
    @IBOutlet var translationTextView: NSTextView!
    
    lazy var cuneiformDocumentView: NSTextView = {return cuneiformView.documentView as! NSTextView}()
    lazy var transliterationDocumentView: NSTextView = {return transliterationView.documentView as! NSTextView}()
    lazy var normalisationDocumentView: NSTextView = {return normalisationView.documentView as! NSTextView}()
    lazy var translationDocumentView: NSTextView = {return translationView.documentView as! NSTextView}()
    
    
    
    var text: OraccTextEdition? {
        didSet {
            self.cuneiform = text?.cuneiform
            self.transliteration = text?.formattedTransliteration(withFont: NSFont.systemFont(ofSize: NSFont.systemFontSize))
            self.normalisation = text?.formattedNormalisation(withFont: NSFont.systemFont(ofSize: NSFont.systemFontSize))
            self.translation = text?.scrapeTranslation ?? text?.literalTranslation
        }
    }
    
    var catalogueData: OraccCatalogEntry? {
        didSet {
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
}
