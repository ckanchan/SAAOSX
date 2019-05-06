//
//  NoteSQLExport.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 29/04/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc
import SQLite
import os

enum ExportFormat {
    case RichTextFormat, MicrosoftWord, PlainText
}

extension NoteSQLDatabase {
    func exportNotes(forDocument document: TextID,
                     metadata: OraccCatalogEntry,
                     exportFormat: ExportFormat) -> Data? {
        
        let exportedString = NSMutableAttributedString()
        if let note = self.retrieveNote(forID: document) {
            exportedString.append(note.formatted(withMetadata: metadata))
        }
        
        let annotations = retrieveAnnotations(forID: document)
        if let formattedAnnotations = annotations.formatted(withMetadata: metadata) {
            exportedString.append(formattedAnnotations)
        }
        
        guard !exportedString.string.isEmpty else {
            os_log("Attempted to export notes for a text %s with no notes or annotations",
                   log: Log.NoteSQLite,
                   type: .info,
                   String(document))
            return nil
        }
        
        let docType: NSAttributedString.DocumentType
        
        switch exportFormat {
        case .RichTextFormat:
            docType = .rtf
        case .MicrosoftWord:
            docType = .officeOpenXML
        case .PlainText:
            return exportedString.string.data(using: .utf8)
        }
        
        let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [
            .documentType: docType,
            .title: metadata.title
        ]
        
        return try? exportedString.data(from: NSMakeRange(0, exportedString.length), documentAttributes: documentAttributes)
    }
}
