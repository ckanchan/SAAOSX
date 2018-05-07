//
//  TextStackView.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 07/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit

extension UIStackView {
    
    func makeTextStackView() -> UIStackView {
        let textView: UITextView = {
            let textView = UITextView()
            return textView
        }()
        
        
        let control: UISegmentedControl = {
            let segments = ["Cuneiform", "Transliteration", "Normalisation", "Translation"]
            let segmentedControl = UISegmentedControl(items: segments)
            return segmentedControl
        }()
        
        let stackView = UIStackView.init(arrangedSubviews: [textView, control])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
        
    }
}
