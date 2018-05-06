//
//  DetailViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 06/03/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import CDKSwiftOracc


class TextEditionViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textControl: UISegmentedControl!
    
    static let defaultFormattingPreferences = UIFont.defaultFont.makeDefaultPreferences()
    
    var detailItem: OraccCatalogEntry? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    var textStrings: TextEditionStringContainer? {
        didSet {
            textStrings?.render(withPreferences: TextEditionViewController.defaultFormattingPreferences)
            configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        textControl?.selectedSegmentIndex = 2
        textView?.attributedText = textStrings?.normalisation
        
        navigationItem.title = detailItem?.title
    }
    
    override func viewDidLoad() {
        configureView()
        configureToolBar(withText: "Quick define")
    }

    func configureToolBar(withText text: String) {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        
        let toolbarItem = UIBarButtonItem(customView: label)
        self.setToolbarItems([toolbarItem], animated: true)
    }

    @IBAction func changeText(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            textView.text = textStrings?.cuneiform
            textView.font = UIFont.cuneiformNA
        case 1:
            textView.attributedText = textStrings?.transliteration
        case 2:
            textView.attributedText = textStrings?.normalisation
        default:
            textView.font = UIFont.defaultFont
            textView.text = textStrings?.translation
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        switch textControl.selectedSegmentIndex {
        case 2:
            // All kinds of cryptic safety checks which need refactoring.
            let selectedRange = textView.selectedRange
            guard let textRange = textView.selectedTextRange else {return}
            guard let text = textView.text(in: textRange) else {return}
            guard  text != "" else { return }
            
            let selection = textView.attributedText.attributedSubstring(from: selectedRange)
            let attributes = selection.attributes(at: 0, effectiveRange: nil)
            let guideWord = attributes[.oraccGuideWord] as? String
            let word = attributes[.oraccCitationForm] as? String
            let sense = attributes[.oraccSense] as? String
            let partOfSpeech = attributes[.partOfSpeech] as? String
            let writtenForm = attributes[.writtenForm] as? String
            
            let detailString =  "\(word ?? ""): \(guideWord ?? ""), \(sense ?? "") \(partOfSpeech ?? "") \(writtenForm ?? "")"
            
            configureToolBar(withText: detailString)
        default:
            return
        }
    }
    
    


}

