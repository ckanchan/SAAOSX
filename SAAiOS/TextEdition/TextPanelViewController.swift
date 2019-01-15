//
//  TextPanelViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 11/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit

class TextPanelViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    weak var delegate: TextEditionViewController?

    var textDisplay: TextDisplay! {
        didSet {
            guard let newString = delegate?.string(for: textDisplay) else {return}
            textView.attributedText = newString
            if textDisplay == .Normalisation {
                highlightSearchTerm(delegate?.searchTerm)
            }
            segmentedControl.selectedSegmentIndex = textDisplay.rawValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
    }

    func highlightSearchTerm(_ searchTerm: String?) {
        guard let searchTerm = searchTerm else {return}

        textView.textStorage.enumerateAttribute(.oraccCitationForm, in: NSRange(location: 0, length: textView.textStorage.length), options: .longestEffectiveRangeNotRequired, using: {
            value, range, _ in
            guard let stringVal = value as? String else {return}
            if searchTerm.lowercased() == stringVal.lowercased() {
                guard range.length > 2 else {return}
                let newRange = NSRange(location: range.location, length: range.length - 1)
                textView.textStorage.addAttributes([NSAttributedStringKey.backgroundColor: UIColor.yellow, NSAttributedStringKey.foregroundColor: UIColor.black], range: newRange)
            }
        })
    }

    @IBAction func changeText(_ sender: UISegmentedControl) {
        guard let newText = TextDisplay.init(rawValue: sender.selectedSegmentIndex) else {return}

        self.textDisplay = newText
    }

    func textViewDidChangeSelection(_ textView: UITextView) {

        if textDisplay == .Normalisation {

            let selectedRange = textView.selectedRange
            guard let textRange = textView.selectedTextRange else {return}
            guard let text = textView.text(in: textRange) else {return}
            guard  text != "" else { return }

            let selection = textView.attributedText.attributedSubstring(from: selectedRange)
            let attributes = selection.attributes(at: 0, effectiveRange: nil)
            let guideWord = attributes[.oraccGuideWord] as? String
            let word = attributes[.oraccCitationForm] as? String
           // let sense = attributes[.oraccSense] as? String
            
            
            if let citationForm = word {
                guard !citationForm.isEmpty else {delegate?.configureToolBar(withAttributedText: NSAttributedString(string:"")); return}
                
                let italicWord = NSAttributedString(string: word ?? "", attributes: [NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)])
                let boldGuideWord = NSAttributedString(string: guideWord ?? "", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)])
                
                let detail = NSMutableAttributedString(attributedString: italicWord)
                detail.append(NSAttributedString(string: " "))
                detail.append(boldGuideWord)
                
                
                delegate?.configureToolBar(withAttributedText: detail)
            } else {
                delegate?.configureToolBar(withAttributedText: NSAttributedString(string:""))
            }
        }
    }
}
