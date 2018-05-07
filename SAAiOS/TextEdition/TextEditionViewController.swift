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
    @IBOutlet weak var stackView: UIStackView!
    
    static let defaultFormattingPreferences: OraccTextEdition.FormattingPreferences = UIFont.defaultFont.makeDefaultPreferences()
    
    var textItem: OraccCatalogEntry? {
        didSet {
        }
    }
    
    var textStrings: TextEditionStringContainer? {
        didSet {
            textStrings?.render(withPreferences: TextEditionViewController.defaultFormattingPreferences)
        }
    }
    
    enum TextDisplay {
        case Cuneiform, Transliteration, Normalisation, Translation
    }
    
    enum DisplayState {
        case single(TextDisplay)
        case double(left: TextDisplay, right: TextDisplay)
    }
    
    var displayState: DisplayState? = nil

    
    override func viewDidLoad() {
        navigationItem.title = textItem?.title
        stackView.distribution = .fillEqually
        let leftColumn = UIStackView.makeTextStackView(textViewTag: 0, controlTag: 0)
        let rightColumn = UIStackView.makeTextStackView(textViewTag: 1, controlTag: 1)
        stackView.addArrangedSubview(leftColumn)

        guard let margins = leftColumn.superview?.layoutMarginsGuide else {return}
        leftColumn.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        leftColumn.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        stackView.addArrangedSubview(rightColumn)
        
        
        configureStackViews()
        configureToolBar(withText: "Quick define")
    }
    
    func configureStackViews() {
        if self.stackView.arrangedSubviews.count == 1 {
            guard let view = stackView.arrangedSubviews.first as? UIStackView else {return}
            guard let textView = view.arrangedSubviews[0] as? UITextView else {return}
            guard let segmentedControl = view.arrangedSubviews[1] as? UISegmentedControl else {return}
            
            textView.attributedText = textStrings?.transliteration
            segmentedControl.selectedSegmentIndex = 1
            segmentedControl.addTarget(self, action: #selector(changeText), for: .valueChanged)
            setState(isSingleColumn: true)
            
            
        } else if self.stackView.arrangedSubviews.count == 2 {
            guard let leftView = stackView.arrangedSubviews[0] as? UIStackView else {return}
            guard let rightView = stackView.arrangedSubviews[1] as? UIStackView else {return}
            
            guard let leftTextView = leftView.arrangedSubviews[0] as? UITextView else {return}
            guard let leftControl =  leftView.arrangedSubviews[1] as? UISegmentedControl else {return}
            leftTextView.attributedText = textStrings?.transliteration
            
            leftControl.selectedSegmentIndex = 1
            leftControl.addTarget(self, action: #selector(changeText), for: .valueChanged)
            
            
            guard let rightTextView = rightView.arrangedSubviews[0] as? UITextView else {return}
            guard let rightControl = rightView.arrangedSubviews[1] as? UISegmentedControl else {return}
            rightTextView.text = textStrings?.translation
            rightControl.selectedSegmentIndex = 3
            rightControl.addTarget(self, action: #selector(changeText), for: .valueChanged)
            
            setState(isSingleColumn: false)
            
            
            stackView.distribution = .fillEqually
        }
    }
    
    func setState(isSingleColumn: Bool) {
        if isSingleColumn {
            self.displayState = DisplayState.single(.Transliteration)
        } else {
            self.displayState = DisplayState.double(left: .Transliteration,
                                                    right: .Translation)
        }
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
        guard let displayState = self.displayState else {return}
        let newState: TextDisplay
        switch sender.selectedSegmentIndex {
        case 0:
            newState = .Cuneiform
        case 1:
            newState = .Transliteration
        case 2:
            newState = .Normalisation
        case 3:
            newState = .Translation
        default:
            newState = .Normalisation
        }
        
        
        switch displayState {
        case .single(_):
            guard let textView = self.stackView.subviews[0].subviews.first as? UITextView else {return}
            switchTextTo(newState, textView: textView)
            self.displayState = DisplayState.single(newState)
            
        case .double(let leftDisplay, let rightDisplay):
            let textViewToChange: UITextView
            let newDisplayState: DisplayState
            
            switch sender.tag {
            case 0: // Changing the left display's text
                guard let textView = self.stackView.subviews[0].subviews.first as? UITextView else {return}
                textViewToChange = textView
                newDisplayState = DisplayState.double(left: newState, right: rightDisplay)
                
            case 1: // Changing the right display's text
                guard let textView = self.stackView.subviews[1].subviews.first as? UITextView else {return}
                textViewToChange = textView
                newDisplayState = DisplayState.double(left: leftDisplay, right: newState)
                
            default: // Big error
                return
            }
            
            switchTextTo(newState, textView: textViewToChange)
            self.displayState = newDisplayState
            
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
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
    }
    
    
    
    
    func switchTextTo(_ text: TextDisplay, textView: UITextView) {
        switch text {
        case .Cuneiform:
            textView.text = textStrings?.cuneiform
            textView.font = UIFont.cuneiformNA
            textView.delegate = nil
        case .Transliteration:
            textView.attributedText = textStrings?.transliteration
            textView.delegate = nil
        case .Normalisation:
            textView.attributedText = textStrings?.normalisation
            textView.delegate = self
        case .Translation:
            textView.font = UIFont.defaultFont
            textView.text = textStrings?.translation
            textView.delegate = nil
        }
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

            let leftColumn = stackView.arrangedSubviews[0]
            let rightColumn = stackView.arrangedSubviews[1]

            switch traitCollection.horizontalSizeClass {
            case .regular:
                leftColumn.isHidden = false
                rightColumn.isHidden = false

            default:
//                activateSingleColumnViewConstraints(leftColumn)
                leftColumn.isHidden = false
                rightColumn.isHidden = true
                
            }
      
    
    }
}

