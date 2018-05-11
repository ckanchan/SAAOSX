//
//  ViewControllerExtensions.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 06/03/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var sqlite: SQLiteCatalogue {
        return appDelegate.sqlDB
    }
    
    var glossary: Glossary {
        return appDelegate.glossaryDB
    }
}

// Storyboard IDs
extension UIViewController {
    enum StoryboardIDs {
        static var TextEditionViewController: String {
            return "TextEditionViewController"
        }
        
        static var InfoTableViewController: String {
            return "InfoTableViewController"
        }
        
        static var Glossary: String {
            return "Glossary"
        }
        
        static var ProjectListViewController: String {
            return "ProjectListViewController"
        }
        
        static var PreferencesViewController: String {
            return "PreferencesViewController"
        }
    }
}


