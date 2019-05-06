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
    
    static var tagsDidChange: Notification.Name {
                return Notification.Name(rawValue: "tagsDidChange")
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
    static func annotationAdded(reference: NodeReference, tags: Set<Tag>) -> Notification {
        return Notification(
            name: .annotationAdded,
            object: nil,
            userInfo: ["nodeReference": reference, "tags": tags])
    }
    
    static func annotationUpdated(reference: NodeReference, tags: Set<Tag>) -> Notification {
        return Notification(
            name: .annotationUpdated,
            object: nil,
            userInfo: ["nodeReference": reference, tags: tags])
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
    
    func annotationMetadata() -> (NodeReference, Set<Tag>)? {
        guard let userInfo = self.userInfo as? [String: Any],
            let nodeReference = userInfo["nodeReference"] as? NodeReference,
            let tags = userInfo["tags"] as? Set<Tag> else {return nil}
        
        return (nodeReference: nodeReference, tags: tags)
    }
}

extension Notification {
    static var tagsDidChange: Notification {
        return Notification(name: .tagsDidChange)
    }
}
