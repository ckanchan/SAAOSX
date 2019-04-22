//
//  CKRecord+Conversions.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 01/01/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc
import CloudKit.CKRecord

extension CKRecord {
    enum RecordType {
        static let Annotation = "Annotation"
        static let Note = "Note"
        static let Tags = "Tags"
    }
    
    convenience init(note: Note) {
        let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: NoteType.Note.zone.zoneID)
        self.init(recordType: CKRecord.RecordType.Note, recordID: recordID)
        self["textID"] = note.id.description
        self["notes"] = note.notes
    }
    
    convenience init (annotation: Annotation) {
        let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: NoteType.Annotation.zone.zoneID)
        self.init(recordType: CKRecord.RecordType.Annotation, recordID: recordID)
        self["textID"] = annotation.nodeReference.base.description
        self["nodeReference"] = annotation.nodeReference.description
        self["transliteration"] = annotation.transliteration
        self["normalisation"] = annotation.normalisation
        self["translation"] = annotation.translation
        self["context"] = annotation.context
        self["annotation"] = annotation.annotation
        self["tags"] = Array(annotation.tags)
    }
    
    convenience init(userTags: UserTags) {
        let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: NoteType.Tag.zone.zoneID)
        self.init(recordType: CKRecord.RecordType.Tags, recordID: recordID)
        self["tags"] = Array(userTags.tags)
    }
}

extension Note {
    init?(ckRecord: CKRecord) {
        guard ckRecord.recordType == CKRecord.RecordType.Note else {return nil}
        guard let textIDStr = ckRecord["textID"] as? String,
            let note = ckRecord["notes"] as? String else {return nil}
        
        self.id = TextID.init(stringLiteral: textIDStr)
        self.notes = note
    }
}

extension Annotation {
    init?(ckRecord: CKRecord) {
        guard ckRecord.recordType == CKRecord.RecordType.Annotation else {return nil}
        guard let nodeReferenceStr = ckRecord["nodeReference"] as? String,
            let transliteration = ckRecord["transliteration"] as? String,
            let normalisation = ckRecord["normalisation"] as? String,
            let translation = ckRecord["translation"] as? String,
            let context = ckRecord["context"] as? String,
            let annotationText = ckRecord["annotation"] as? String else {return nil}

        let tags = ckRecord["tags"] as? [String] ?? []
        self.nodeReference = NodeReference(stringLiteral: nodeReferenceStr)
        self.transliteration = transliteration
        self.normalisation = normalisation
        self.translation = translation
        self.annotation = annotationText
        self.context = context
        self.tags = Set(tags)
    }
}

extension UserTags {
    init?(ckRecord: CKRecord) {
        guard ckRecord.recordType == CKRecord.RecordType.Tags,
            let tags = ckRecord["tags"] as? [String] else {return nil}
        
        self.tags = Set(tags)
    }
}
