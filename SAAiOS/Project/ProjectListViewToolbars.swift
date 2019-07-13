//
//  ProjectListViewToolbars.swift
//  Tupšenna
//
//  Created by Chaitanya Kanchan on 13/07/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import UIKit

extension ProjectListViewController {
    enum Toolbar {
        static var glossaryButton: UIBarButtonItem {
            return UIBarButtonItem(title: "Glossary",
                                   style: .plain,
                                   target: self,
                                   action: #selector(showGlossary))
        }
        
        static var preferencesButton: UIBarButtonItem {
            return UIBarButtonItem(title: "⚙︎",
                                   style: .plain,
                                   target: self,
                                   action: #selector(loadPreferences))
        }
        
        static var helpButton: UIBarButtonItem {
            return UIBarButtonItem(title: "?",
                                   style: .plain,
                                   target: self,
                                   action: #selector(showHelp))
        }
        
        static var flexibleSpace: UIBarButtonItem {
            return UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                   target: nil,
                                   action: nil)
        }
        
        static var defaultToolbarItems: [UIBarButtonItem] {
            return [Toolbar.flexibleSpace, glossaryButton]
        }
    }
    
    func configureToolbars() {
        switch catalogue.source {
        case .search:
            let label = UILabel()
            label.text = catalogue.name
            let labelBtn = UIBarButtonItem(customView: label)
            self.setToolbarItems([labelBtn], animated: true)
            navigationItem.title = "Search results"
        default:
            setToolbarItems(Toolbar.defaultToolbarItems, animated: false)
            navigationItem.leftBarButtonItem = Toolbar.preferencesButton
            navigationItem.rightBarButtonItem = Toolbar.helpButton
            navigationItem.title = "Tupšenna"
        }
    }
}
