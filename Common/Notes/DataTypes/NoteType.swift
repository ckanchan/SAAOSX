//
//  NoteType.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 06/04/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CloudKit

enum NoteType: CaseIterable {
    case Note, Annotation, Tag
}

extension NoteType {
    var zoneIDKey: String {
        switch self {
        case .Note:
            return "noteZoneID"
        case .Annotation:
            return "annotationZoneID"
        case .Tag:
            return "tagZoneID"
        }
    }
    
    var zone: CKRecordZone {
        switch self {
        case .Note:
            return CKRecordZone(zoneName: "Notes")
        case .Annotation:
            return CKRecordZone(zoneName: "Annotations")
        case .Tag:
            return CKRecordZone(zoneName: "Tags")
        }
    }
    
    var changeTokenKey: String {
        switch self {
        case .Note:
            return "CloudKitNoteZoneChangeTokenKey"
        case .Annotation:
            return "CloudKitAnnotationZoneChangeTokenKey"
        case .Tag:
            return "CloudKitTagZoneChangeTokenKey"
        }
    }
    
    static func fromString(_ s: String) -> NoteType? {
        switch s {
        case "Note", "Notes":
            return .Note
        case "Annotation", "Annotations":
            return .Annotation
        case "Tag", "Tags":
            return .Tag
        default:
            return nil
        }
    }
}
