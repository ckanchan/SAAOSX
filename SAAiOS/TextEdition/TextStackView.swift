//
//  TextStackView.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 07/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit

extension UIStackView {
    static func makeTextStackView(textViewTag: Int, controlTag: Int) -> UIStackView {
        let textView: UITextView = {
            let textView = UITextView()
            textView.isEditable = false
            textView.isSelectable = true
            textView.tag = textViewTag
            return textView
        }()


        let control: UISegmentedControl = {
            let segments = ["Cuneiform", "Transliteration", "Normalisation", "Translation"]
            let segmentedControl = UISegmentedControl(items: segments)
            segmentedControl.apportionsSegmentWidthsByContent = true
            segmentedControl.tag = controlTag
            return segmentedControl
        }()

        let stackView = UIStackView.init(arrangedSubviews: [textView, control])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill

        return stackView

    }
}
