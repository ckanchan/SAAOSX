//
//  UserDefaultsController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 23/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation

enum PreferenceKey: String {
    case textWindowNumber
    case useGithub
    case userTags
}

class UserDefaultsController {
    lazy var defaults: UserDefaults = {
        return UserDefaults.standard
    }()

    var textWindow: Int {
        return defaults.integer(forKey: PreferenceKey.textWindowNumber.rawValue)
    }

    var useGithub: Bool {
        return defaults.bool(forKey: PreferenceKey.useGithub.rawValue)
    }
    
    var userTags: Set<String> {
        let tags = defaults.array(forKey: PreferenceKey.userTags.rawValue) as? [String] ?? []
        return Set(tags)
    }

    func saveTextPreference(_ number: Int) {
        defaults.set(number, forKey: PreferenceKey.textWindowNumber.rawValue)
    }

    func saveInterfaceSource(_ isGithub: Bool) {
        if isGithub {
            defaults.set(isGithub, forKey: PreferenceKey.useGithub.rawValue)
        }
    }
    
    func saveTags(_ tags: Set<String>) {
        let tags = Array(tags)
        defaults.set(tags, forKey: PreferenceKey.userTags.rawValue)
    }

}
