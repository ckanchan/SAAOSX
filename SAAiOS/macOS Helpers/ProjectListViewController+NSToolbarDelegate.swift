//
//  ProjectListViewController+NSToolbarDelegate.swift
//  SAAi
//
//  Created by Chaitanya Kanchan on 11/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation

#if targetEnvironment(UIKitForMac)
extension ProjectListViewController: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        let button: UIBarButtonItem
        
        switch itemIdentifier {
        case .navigateLeft:
            button = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(navigateLeft))
           
        case .navigateRight:
            button = UIBarButtonItem(image: UIImage(systemName: "chevron.right"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(navigateRight))
            
        case .glossary:
            button = UIBarButtonItem(image: UIImage(systemName: "list.bullet"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(showGlossary))
            
        case .info:
            button = UIBarButtonItem(image: UIImage(systemName: "info.circle"),
                                     style: .plain,
                                     target: self,
                                     action: nil)
            
        default:
            return nil
        }
        
         return NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: button)
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.navigateLeft, .navigateRight, .flexibleSpace, .info]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    @objc func navigateLeft(_ sender: Any?) {
        detailViewController?.navigateIn(.left)
    }
    
    @objc func navigateRight(_ sender: Any?) {
        detailViewController?.navigateIn(.right)
    }
}

extension NSToolbarItem.Identifier {
 
    static var navigateLeft: NSToolbarItem.Identifier {
        return NSToolbarItem.Identifier(rawValue: "navigateLeft")
    }
    
    static var navigateRight: NSToolbarItem.Identifier {
        return NSToolbarItem.Identifier(rawValue: "navigateRight")
    }
    
    static var glossary: NSToolbarItem.Identifier {
        return NSToolbarItem.Identifier(rawValue: "glossary")
    }
    
    static var info: NSToolbarItem.Identifier {
        return NSToolbarItem.Identifier("info")
    }
}
#endif
