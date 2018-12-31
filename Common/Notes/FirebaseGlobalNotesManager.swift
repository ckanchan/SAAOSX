//
//  FirebaseGlobalNotesManager.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc

protocol NoteDelegate: AnyObject {
    func noteAdded(_ note: Note)
    func noteRemoved(_ textID: TextID)
    func noteChanged(_ note: Note)
    
    func searchResultsUpdated(_ notes: [Note])
}
