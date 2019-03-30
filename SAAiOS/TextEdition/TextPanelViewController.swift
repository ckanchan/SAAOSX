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

    var textDisplay: TextDisplay!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        changeText(display: self.textDisplay ?? .Normalisation, scrollToTop: true)
    }

    func highlightSearchTerm(_ searchTerm: String?) {
        guard let searchTerm = searchTerm else {return}

        textView.textStorage.enumerateAttribute(.oraccCitationForm, in: NSRange(location: 0, length: textView.textStorage.length), options: .longestEffectiveRangeNotRequired, using: {
            value, range, _ in
            guard let stringVal = value as? String else {return}
            if searchTerm.lowercased() == stringVal.lowercased() {
                guard range.length > 2 else {return}
                let newRange = NSRange(location: range.location, length: range.length - 1)
                textView.textStorage.addAttributes([NSAttributedString.Key.backgroundColor: UIColor.yellow, NSAttributedString.Key.foregroundColor: UIColor.black], range: newRange)
            }
        })
    }
    
    func changeText(display: TextDisplay, scrollToTop: Bool) {
        guard let newString = delegate?.string(for: display) else {return}
        textView.attributedText = newString
        scrollToTop ? textView.scrollRangeToVisible(NSMakeRange(0, 0)) : ()
        scrollToTop ? textView.setContentOffset(.zero, animated: true) : ()
        
        if textDisplay == .Normalisation {
            highlightSearchTerm(delegate?.searchTerm)
        }
        
        segmentedControl.selectedSegmentIndex = display.rawValue
    }

    @IBAction func changeText(_ sender: UISegmentedControl) {
        guard let newText = TextDisplay.init(rawValue: sender.selectedSegmentIndex) else {return}
        changeText(display: newText, scrollToTop: false)
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
                
                let italicWord = NSAttributedString(string: word ?? "", attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)])
                let boldGuideWord = NSAttributedString(string: guideWord ?? "", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)])
                
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


extension TextPanelViewController {
    static func new(delegate: TextEditionViewController, textDisplay: TextDisplay) -> TextPanelViewController? {
        let storyboard = UIStoryboard(name: "TextEdition", bundle: nil)
        guard let textPanelVC = storyboard.instantiateViewController(withIdentifier: "TextPanelViewController") as? TextPanelViewController else {return nil}
        textPanelVC.delegate = delegate
        textPanelVC.textDisplay = textDisplay
        return textPanelVC
    }
}
