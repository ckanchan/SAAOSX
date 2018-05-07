//
//  CustomKeyboardKeys.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 07/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//


import UIKit

@objc protocol TextToolbarInput: AnyObject {
    func addText(_ sender: UIBarButtonItem)
    func addShortcuts()
}


extension TextToolbarInput {
    var ā: UIBarButtonItem {
        return UIBarButtonItem(title: "ā", style: .plain, target: self, action: #selector(self.addText(_:)))
    }
    
    var ē: UIBarButtonItem {
        return UIBarButtonItem(title: "ē", style: .plain, target: self, action: #selector(self.addText(_:)))
    }
    
    var ī: UIBarButtonItem {
        return UIBarButtonItem(title: "ī", style: .plain, target: self, action: #selector(self.addText(_:)))
    }
    
    var ū: UIBarButtonItem {
        return UIBarButtonItem(title: "ū", style: .plain, target: self, action: #selector(self.addText(_:)))
    }
    
    var ḫ: UIBarButtonItem {
        return UIBarButtonItem(title: "ḫ", style: .plain, target: self, action: #selector(self.addText(_:)))
    }
    
    var š: UIBarButtonItem {
        return UIBarButtonItem(title: "š", style: .plain, target: self, action: #selector(self.addText(_:)))
    }
    var ṣ: UIBarButtonItem {
        return UIBarButtonItem(title: "ṣ", style: .plain, target: self, action: #selector(self.addText(_:)))}
    
    var ṭ: UIBarButtonItem {
        return UIBarButtonItem(title: "ṭ", style: .plain, target: self, action: #selector(self.addText(_:)))
    }
    
    var spacer: UIBarButtonItem {
        return UIBarButtonItem(title: "\t", style: .plain, target: nil, action: nil)
    }
    
    func makeToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.setItems([ā, spacer, ē, spacer, ī, spacer, ū, spacer, ḫ, spacer, š, spacer, ṣ, spacer, ṭ], animated: false)
        toolbar.isUserInteractionEnabled = true
        toolbar.sizeToFit()

        
        return toolbar
    }
    
    func makeVowelGroup() -> UIBarButtonItemGroup {
        let representative = UIBarButtonItem(title: "Vowels", style: .plain, target: nil, action: nil)
        return UIBarButtonItemGroup(barButtonItems: [ā, ē, ī, ū], representativeItem: representative)
    }
    
    func makeConsonantGroup() -> UIBarButtonItemGroup {
        let representative = UIBarButtonItem(title: "Consonants", style: .plain, target: nil, action: nil)
        return UIBarButtonItemGroup(barButtonItems: [ḫ, š, ṣ, ṭ], representativeItem: representative)
    }
    
    var barButtonGroups: [UIBarButtonItemGroup] {
        return [makeVowelGroup(), makeConsonantGroup()]
    }
}



extension UISearchBar: TextToolbarInput {
    @objc func addText(_ sender: UIBarButtonItem) {
        if let text = sender.title {
            self.text?.append(text)
        }
    }
    
    func addShortcuts() {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            addInputAssistant()
        default:
            addToolbar()
        }
    }
    
    func addToolbar() {
        self.inputAccessoryView = makeToolBar()
    }
    
    func addInputAssistant() {
        self.inputAssistantItem.leadingBarButtonGroups = barButtonGroups
    }
}

extension UITextField: TextToolbarInput {
    @objc func addText(_ sender: UIBarButtonItem) {
        if let text = sender.title {
            self.text?.append(text)
        }
    }
    
    func addShortcuts() {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            addInputAssistant()
        default:
            addToolbar()
        }
    }
    
    func addToolbar() {
        self.inputAccessoryView = makeToolBar()
    }
    
    func addInputAssistant() {
        self.inputAssistantItem.leadingBarButtonGroups = barButtonGroups
    }
}
