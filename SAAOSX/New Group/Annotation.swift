//
//  Annotation.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class Annotation: NSCollectionViewItem {
    @IBOutlet weak var normalisationLabel: NSTextField!
    @IBOutlet weak var transliterationLabel: NSTextField!
    @IBOutlet weak var contextLabel: NSTextField!
    @IBOutlet weak var tagField: NSTokenField!
    @IBOutlet var annotationView: NSTextView!
    
    var annotation: Note.Annotation! {
        didSet {
            normalisationLabel.stringValue = annotation.normalisation
            transliterationLabel.stringValue = annotation.transliteration
            contextLabel.stringValue = annotation.context
            tagField.stringValue = annotation.tags.joined(separator: " ")
            annotationView.string = annotation.annotation
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
