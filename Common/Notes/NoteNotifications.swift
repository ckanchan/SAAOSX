//
//  NoteNotifications.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 22/04/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc

extension Notification.Name {
    static var noteAdded: Notification.Name {
        return Notification.Name(rawValue: "noteAdded")
    }
    
    static var noteUpdated: Notification.Name {
        return Notification.Name(rawValue: "noteUpdated")
    }
    
    static var noteDeleted: Notification.Name {
        return Notification.Name(rawValue: "noteDeleted")
    }
    
    static var annotationAdded: Notification.Name {
        return Notification.Name(rawValue: "annotationAdded")
    }
    
    static var annotationUpdated: Notification.Name {
        return Notification.Name(rawValue: "annotationUpdated")
    }
    
    static var annotationDeleted: Notification.Name {
        return Notification.Name(rawValue: "annotationDeleted")
    }
    
    static var annotationsChangedForText: Notification.Name {
        return Notification.Name(rawValue: "annotationsChangedForText")
    }
}

extension Notification {
    static func noteAdded(id: TextID) -> Notification {
        return Notification(
            name: .noteAdded,
            object: nil,
            userInfo: ["textID": id])
    }
    
    static func noteUpdated(id: TextID) -> Notification {
        return Notification(
            name: .noteUpdated,
            object: nil,
            userInfo: ["textID": id])
    }
    
    static func noteDeleted(id: TextID) -> Notification {
        return Notification(
            name: .noteDeleted,
            object: nil,
            userInfo: ["textID": id])
    }
}

extension Notification {
    static func annotationAdded(reference: NodeReference) -> Notification {
        return Notification(
            name: .annotationAdded,
            object: nil,
            userInfo: ["nodeReference": reference])
    }
    
    static func annotationUpdated(reference: NodeReference) -> Notification {
        return Notification(
            name: .annotationUpdated,
            object: nil,
            userInfo: ["nodeReference": reference])
    }
    
    static func annotationDeleted(reference: NodeReference) -> Notification {
        return Notification(
            name: .annotationDeleted,
            object: nil,
            userInfo: ["nodeReference": reference])
    }
    
    static func annotationsChanged(for text: TextID) -> Notification {
        return Notification(
            name: .annotationsChangedForText,
            object: nil,
            userInfo: ["textID": text])
    }
}