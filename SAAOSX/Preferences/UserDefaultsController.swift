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
    case userTags
    case downloadedVolumes
}

class UserDefaultsController {
    lazy var defaults: UserDefaults = {
        return UserDefaults.standard
    }()

    var textWindow: Int {
        return defaults.integer(forKey: PreferenceKey.textWindowNumber.rawValue)
    }
    

    func saveTextPreference(_ number: Int) {
        defaults.set(number, forKey: PreferenceKey.textWindowNumber.rawValue)
    }
    
    var downloadedVolumes: Set<String> {
        get {
            return Set(UserDefaults.standard.stringArray(forKey: PreferenceKey.downloadedVolumes.rawValue) ?? [])
        } set {
            return UserDefaults.standard.set(Array(newValue), forKey: PreferenceKey.downloadedVolumes.rawValue)
        }
    }
}
