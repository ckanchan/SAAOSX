//
//  UserTags.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation

typealias Tag = String

struct UserTags: Codable, Equatable {
    var tags: Set<Tag>
}

extension UserTags {
    init(_ tags: [Tag]) {
        self.tags = Set(tags)
    }
}

protocol TagDisplaying: AnyObject {
    func tagsDidChange(_ tags: UserTags)
}
