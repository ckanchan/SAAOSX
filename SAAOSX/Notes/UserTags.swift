//
//  UserTags.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation

import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

struct UserTags: Codable {
    var tags: Set<String>
}

extension UserTags {
    init(withFirebaseData data: [String]) {
        self.tags = Set(data)
    }
    
    var firebaseData: [String: Any] {
        return ["usertags": Array(tags)]
    }
}

protocol TagDisplaying: AnyObject {
    func tagsDidChange(_ tags: UserTags)
}

class FirebaseTagManager {
    private let db = Database.database().reference()
    weak var delegate: TagDisplaying?
    let user: User
    
    lazy var listener: DatabaseHandle = {
        return db.child("users").child(user.uid).child("tags").observe(.value) { snapshot in
            guard let rawValue = snapshot.value else {return}
            guard let tagArray = rawValue as? Array<String> else {return}
            let tags = UserTags(withFirebaseData: tagArray)
            self.delegate?.tagsDidChange(tags)
        }
    }()
    
    func set(tags: UserTags) {
        let tags = Array(tags.tags)
        db.child("users").child(user.uid).child("tags").setValue(tags)
    }
    
    init(for user: User, delegate: TagDisplaying) {
        self.user = user
        self.delegate = delegate
        print("Initialised \(listener)")
    }
    
    deinit {
        db.removeObserver(withHandle: listener)
    }
    
}
