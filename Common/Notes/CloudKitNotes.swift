//
//  CloudKitNotes.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 31/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CloudKit
import CDKSwiftOracc

final class CloudKitNotes {
    enum Query {
        static func TextID(_ id: TextID) -> NSPredicate {
            let textID = id.description
            return NSPredicate(format: "textID == %@", textID)
        }
    }
    
    var userTags: UserTags {
        get {
            guard let tags = NSUbiquitousKeyValueStore.default.array(forKey: "userTags") as? [Tag] else {return UserTags([])}
            return UserTags(tags)
        } set(tags) {
            let array = Array(tags.tags)
            NSUbiquitousKeyValueStore.default.set(array, forKey: "userTags")
        }
    }
    
    var userIsLoggedIn: Bool {
        didSet {
            if userIsLoggedIn {
                self.retrieveAllNotes {[unowned self] in self.notes = $0}
                self.retrieveAllAnnotations{[unowned self] in self.annotations = $0}
            }
        }
    }
    
    var notes: [TextID: Note] = [:]
    var annotations: [TextID: [Annotation]] = [:]

    
    @objc func userStatusDidChange() {
        CKContainer.default().accountStatus { [weak self] status, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            switch status {
            case .available:
                self?.userIsLoggedIn = true
            case .couldNotDetermine:
                print("Could not determine iCloud user status")
                self?.userIsLoggedIn = false
            default:
                self?.userIsLoggedIn = false
            }
        }
    }
    
    init() {
        userIsLoggedIn = false
        self.userStatusDidChange()
        NotificationCenter.default.addObserver(self, selector: #selector(userStatusDidChange), name: .CKAccountChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}

protocol NoteDelegate: AnyObject {
    func noteAdded(_ note: Note)
    func noteRemoved(_ textID: TextID)
    func noteChanged(_ note: Note)
    
    func searchResultsUpdated(_ notes: [Note])
}
