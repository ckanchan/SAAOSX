//
//  UserTags.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation

struct UserTags: Codable {
    var tags: Set<String>
}


protocol TagDisplaying: AnyObject {
    func tagsDidChange(_ tags: UserTags)
}
