//
//  ViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 09/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift

class ViewController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    @IBAction func toggle(_ sender: NSView) {
//        let editionViewController = self.childViewControllers[1] as! EditionViewController
//        guard editionViewController.text != nil else { return }
//
//        if sender.identifier!.rawValue == "rightSwitch" {
//            if let n = editionViewController.norm {
//                if n {
//                    let attr = NSAttributedString(string: editionViewController.text?.scrapeTranslation ?? "no translation available", attributes: nil)
//                    editionViewController.rightTextView.textStorage?.setAttributedString(NSAttributedString(attributedString: attr))
//
//                    editionViewController.norm = false
//                } else {
//                    editionViewController.rightTextView.textStorage?.setAttributedString(editionViewController.text!.formattedNormalisation(withFont: NSFont.systemFont(ofSize: NSFont.systemFontSize)))
//                    editionViewController.norm = true
//                }
//            }
//        } else if sender.identifier!.rawValue == "leftSwitch" {
//            if let c = editionViewController.cuneiform {
//                if c {
//                    editionViewController.leftTextView.textStorage?.setAttributedString(editionViewController.text!.formattedTransliteration(withFont: NSFont.systemFont(ofSize: NSFont.systemFontSize)))
//
//                    editionViewController.cuneiform = false
//                } else {
//                    let cNA = NSFont(name: "CuneiformNAOutline-Medium", size: NSFont.systemFontSize)
//                    let fontAttr: [NSAttributedStringKey: NSFont] = [.font: cNA!]
//                    let attr = NSAttributedString(string: editionViewController.text!.cuneiform, attributes: fontAttr)
//                    editionViewController.leftTextView.textStorage?.setAttributedString(attr)
//
//                    editionViewController.cuneiform = true
//                }
//            }
//        }
//    }
}

