//
//  PreferencesViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 10/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import FirebaseUI

class PreferencesViewController: UITableViewController {
    @IBOutlet weak var themeStandard: UITableViewCell!
    @IBOutlet weak var themeDark: UITableViewCell!
    @IBOutlet weak var signIn: UITableViewCell!
    
    
    var themeController = ThemeController()


    override func viewWillAppear(_ animated: Bool) {
        showPreferences()
    }

    override func viewDidLoad() {
        registerThemeNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUser), name: .userChange, object: nil)
        refreshUser()
    }
    
    @objc func refreshUser() {
        if let user = userManager.user {
            signIn.textLabel?.text = user.displayName
            signIn.detailTextLabel?.text = user.providerID
        } else {
            signIn.textLabel?.text = "Not logged in"
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func showPreferences() {
        switch themeController.themePreference {
        case .standard:
            themeStandard.accessoryType = .checkmark
            themeDark.accessoryType = .none
        case .dark:
            themeDark.accessoryType = .checkmark
            themeStandard.accessoryType = .none
        }
    }
    
    func toggleUser() {
        if userManager.user == nil {
            guard let viewController = userManager.signIn() else { return }
            present(viewController, animated: true){ [weak self] in
                guard self?.userManager.user != nil else {
                    let alert = UIAlertController(title: "Error signing in", message: "An error occurred", preferredStyle: .alert)
                    let done = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(done)
                    self?.present(alert, animated: true)
                    return
                }
            }
        } else {
            userManager.signOut()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: //Theme section
            switch indexPath.row {
            case 0: //Standard
                themeController.change(theme: .standard)
                tableView.deselectRow(at: indexPath, animated: true)
            case 1: //Dark
                themeController.change(theme: .dark)
                tableView.deselectRow(at: indexPath, animated: true)
            default:
                return
            }
            
        case 1: //Sign In Section
            switch indexPath.row {
            case 0:
                toggleUser()
            default:
                return
            }
        default:
            return
        }

        showPreferences()

    }

}

extension PreferencesViewController: Themeable {
    func enableDarkMode() {
        view.window?.backgroundColor = UIColor.black
        navigationController?.navigationBar.barStyle = .black
        navigationController?.toolbar.barStyle = .black

        self.tableView.enableDarkMode()
        self.tableView.visibleCells.forEach({$0.enableDarkMode()})
    }

    func disableDarkMode() {
        view.window?.backgroundColor = nil
        navigationController?.navigationBar.barStyle = .default
        navigationController?.toolbar.barStyle = .default

        self.tableView.disableDarkMode()
        self.tableView.visibleCells.forEach({$0.disableDarkMode()})
    }
}

enum PreferenceKey: String {
    case Theme
}
