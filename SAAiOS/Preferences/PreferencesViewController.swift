//
//  PreferencesViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 10/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit

class PreferencesViewController: UITableViewController {
    @IBOutlet weak var themeStandard: UITableViewCell!
    @IBOutlet weak var themeDark: UITableViewCell!

    var themeController = ThemeController()

    override func viewWillAppear(_ animated: Bool) {
        showPreferences()
    }

    override func viewDidLoad() {
        registerThemeNotifications()
    }

    deinit {
        deregisterThemeNotifications()
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
