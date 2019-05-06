//
//  NSAttributedStringLineBreaks.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 06/05/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation

extension NSAttributedString {
    static var singleLineBreak: NSAttributedString {
        return NSAttributedString(string: "\n")
    }
    
    static var doubleLineBreak: NSAttributedString {
        return NSAttributedString(string: "\n\n")
    }
}
