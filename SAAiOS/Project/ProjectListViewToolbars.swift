//
//  ProjectListViewToolbars.swift
//  Tupšenna
//
//  Created by Chaitanya Kanchan on 13/07/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import UIKit

extension ProjectListViewController {
        func glossaryButton() -> UIBarButtonItem {
            return UIBarButtonItem(title: "Glossary",
                                   style: .plain,
                                   target: self,
                                   action: #selector(showGlossary))
        }
        
        func preferencesButton() -> UIBarButtonItem {
            return UIBarButtonItem(title: "⚙︎",
                                   style: .plain,
                                   target: self,
                                   action: #selector(loadPreferences))
        }
        
        func helpButton() -> UIBarButtonItem {
            return UIBarButtonItem(title: "?",
                                   style: .plain,
                                   target: self,
                                   action: #selector(showHelp))
        }
        
        func flexibleSpace() -> UIBarButtonItem {
            return UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                   target: nil,
                                   action: nil)
        }
        
        var defaultToolbarItems: [UIBarButtonItem] {
            return [flexibleSpace(), glossaryButton()]
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
            setToolbarItems(defaultToolbarItems, animated: false)
            navigationItem.leftBarButtonItem = preferencesButton()
            navigationItem.rightBarButtonItem = helpButton()
            navigationItem.title = "Tupšenna"
        }
    }
}
