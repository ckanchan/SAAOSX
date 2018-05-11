//
//  UIVIewController+Theming.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 11/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit

extension UITableViewCell: Themeable {
    func enableDarkMode() {
        textLabel?.textColor = .lightText
        detailTextLabel?.textColor = .lightText
        backgroundColor = .black
        
        let colorView = UIView()
        colorView.backgroundColor = UIColor.darkGray
        selectedBackgroundView = colorView
    }
    
    func disableDarkMode() {
        textLabel?.textColor = .darkText
        detailTextLabel?.textColor = .darkText
        backgroundColor = .white

        selectedBackgroundView = nil
    }
    
    
}

extension UITableView: Themeable {
    func enableDarkMode() {
        backgroundColor = .black

    }
    
    func disableDarkMode() {
        backgroundColor = .white
    }
    
    
}

extension UITextView: Themeable {
    func enableDarkMode() {
        backgroundColor = .black
        textColor = .lightText
    }
    
    func disableDarkMode() {
        backgroundColor = .white
        textColor = .darkText
    }
}
