//
//  ThemeController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 10/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import CDKSwiftOracc

extension Notification.Name {
    static let darkModeEnabled = Notification.Name("darkModeEnabled")
    static let darkModeDisabled = Notification.Name("darkModeDisabled")
}

class ThemeController {
    enum Theme: Int {
        case standard, dark
    }

    var themePreference: Theme {
        didSet {
            UserDefaults.standard.set(themePreference.rawValue, forKey: PreferenceKey.Theme.rawValue)
            switch themePreference {
            case .standard:
                NotificationCenter.default.post(name: .darkModeDisabled, object: nil)
            case .dark:
                NotificationCenter.default.post(name: .darkModeEnabled, object: nil)
            }
        }
    }

    var themeFormatting: OraccTextEdition.FormattingPreferences {
        switch self.themePreference {
        case .standard:
            return UIFont.defaultFont.makeDefaultPreferences()
        case .dark:
            return UIFont.defaultFont.makeDarkPreferences()
        }
    }

    func change(theme: Theme) {
        switch theme {
        case .standard:
            UIView.appearance().tintColor = #colorLiteral(red: 1, green: 0.224928888, blue: 0, alpha: 1)

            UITextField.appearance().keyboardAppearance = .default

            UINavigationBar.appearance().barStyle = .default
            UIToolbar.appearance().barStyle = .default
            UITableView.appearance().backgroundColor = .white

            UILabel.appearance().textColor = UIColor.darkText

            UITextView.appearance().backgroundColor = .white
            UITextView.appearance().textColor = UIColor.darkText

            self.themePreference = .standard

        case .dark:

            UIView.appearance().tintColor = #colorLiteral(red: 1, green: 0.224928888, blue: 0, alpha: 1)

            UITextField.appearance().keyboardAppearance = .dark

            UINavigationBar.appearance().barStyle = UIBarStyle.black
            UIToolbar.appearance().barStyle = UIBarStyle.black

            UILabel.appearance().textColor = UIColor.lightText

            UITextView.appearance().backgroundColor = UIColor.black
            UITextView.appearance().textColor = UIColor.lightText

            self.themePreference = .dark
        }
    }

    init() {
        self.themePreference = Theme.init(rawValue: UserDefaults.standard.integer(forKey: PreferenceKey.Theme.rawValue)) ?? Theme.standard
    }

}

@objc protocol Themeable: AnyObject {
    func enableDarkMode()
    func disableDarkMode()

}

extension Themeable {
    func registerThemeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkMode), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableDarkMode), name: .darkModeDisabled, object: nil)
    }

    func deregisterThemeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UIFont {


    func makeDarkPreferences() -> OraccTextEdition.FormattingPreferences {
        let noFormatting = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: UIFont.systemFontSize), NSAttributedStringKey.foregroundColor: UIColor.lightText]
        let italicFormatting: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: self.getItalicFont(), NSAttributedStringKey.foregroundColor: UIColor.lightText]
        let superscriptFormatting: [NSAttributedStringKey: Any] = [NSAttributedStringKey.baselineOffset: 10,
                                                                   NSAttributedStringKey.font: self.reducedFontSize,
                                                                   NSAttributedStringKey.foregroundColor: UIColor.lightText]
        let damagedFormatting: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: self.getItalicFont(), NSAttributedStringKey.foregroundColor: UIColor.gray]
        let damagedLogogram: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: UIFont.systemFontSize), NSAttributedStringKey.foregroundColor: UIColor.gray]

        let editorialFormatting: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.lightText]
        let editorialBoldFormatting: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: UIFont.Weight.bold), NSAttributedStringKey.foregroundColor: UIColor.lightText]

        return OraccTextEdition.FormattingPreferences(editorial: editorialFormatting, editorialBold: editorialBoldFormatting, italic: italicFormatting, superscript: superscriptFormatting, damaged: damagedFormatting, damagedLogogram: damagedLogogram, none: noFormatting)
    }
}
