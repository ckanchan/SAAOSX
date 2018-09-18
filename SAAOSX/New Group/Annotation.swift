//
//  Annotation.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc

class Annotation: NSCollectionViewItem {
    @IBOutlet weak var normalisationLabel: NSTextField!
    @IBOutlet weak var transliterationLabel: NSTextField!
    @IBOutlet weak var contextLabel: NSTextField!
    @IBOutlet weak var tagField: NSTokenField!
    @IBOutlet var annotationView: NSTextView!
    @IBOutlet weak var textLinkButton: NSButton!
    
    var annotation: Note.Annotation! {
        didSet {
            normalisationLabel.stringValue = annotation.normalisation
            transliterationLabel.stringValue = annotation.transliteration
            contextLabel.stringValue = annotation.context
            tagField.objectValue = Array(annotation.tags)
            annotationView.string = annotation.annotation

        }
    }
    
    var catalogueInfo: OraccCatalogEntry? {
        didSet {
            guard let info = self.catalogueInfo else {return}
            textLinkButton.title = "Go to \(info.displayName)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    @IBAction func textLinkClicked(_ sender: Any) {
        guard let info = self.catalogueInfo else {return}
        guard let sql = appDelegate.sqlite else {return}
        DispatchQueue.global(qos: .userInteractive).async {
            guard let strings = sql.getTextStrings(info.id) else {return}
            DispatchQueue.main.async {
                TextWindowController.new(info, strings: strings, catalogue: nil)
            }
        }
    }
    
}
