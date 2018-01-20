//
//  GlossaryEntryViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 20/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift

class GlossaryEntryViewController: NSViewController {
    var glossaryEntry: GlossaryEntry? {
        didSet {
            citationForm.stringValue = glossaryEntry?.citationForm ?? ""
            guideWord.stringValue = glossaryEntry?.guideWord ?? ""
            forms.stringValue = glossaryEntry?.forms?.description ?? ""
            norms.stringValue = glossaryEntry?.norms?.description ?? ""
            senses.stringValue = glossaryEntry?.senses?.description ?? ""
            metadata.stringValue = "Headword: \(glossaryEntry?.headWord ?? ""), id: \(glossaryEntry?.id ?? "")"
        }
    }
    
    @IBOutlet weak var citationForm: NSTextField!
    @IBOutlet weak var guideWord: NSTextField!
    @IBOutlet weak var forms: NSTextField!
    @IBOutlet weak var norms: NSTextField!
    @IBOutlet weak var senses: NSTextField!
    @IBOutlet weak var metadata: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
