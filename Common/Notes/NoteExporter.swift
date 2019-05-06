//
//  NoteExporter.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 04/05/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import AppKit
import CDKSwiftOracc
import SQLite

struct NoteExporter {
    let catalogue: SQLiteCatalogue
    let noteDB: NoteSQLDatabase
    
    func exportAllNotes(to exportFormat: ExportFormat) throws -> Data? {
        var catalogueEntryCache = [TextID: OraccCatalogEntry]()
        var textStrings = [TextID: NSMutableAttributedString]()
        
        let notes = noteDB.retrieveAllNotes()
        let annotations = noteDB.retrieveAllAnnotations()
        
        if notes.isEmpty && annotations.isEmpty {
            return nil
        }
        
        let annotationsDict = Dictionary(grouping: annotations, by: {$0.nodeReference.base})
        
        for note in notes {
            let catalogueEntry = catalogue.getEntryFor(id: note.id)
            textStrings[note.id] = NSMutableAttributedString(attributedString: note.formatted(withMetadata: catalogueEntry))
            catalogueEntryCache[note.id] = catalogueEntry
        }
        
        for textAnnotations in annotationsDict {
            let id = textAnnotations.key
            let catalogueEntry = catalogueEntryCache[id] ?? catalogue.getEntryFor(id: id)
            guard let formattedAnnotations = annotations.formatted(withMetadata: catalogueEntry) else {continue}
            if let preexisting = textStrings[id] {
                preexisting.append(formattedAnnotations)
                textStrings[id] = preexisting
            } else {
                textStrings[id] = NSMutableAttributedString(attributedString: formattedAnnotations)
            }
        }
        
        let finalString = NSMutableAttributedString()
        
        for string in textStrings {
            finalString.append(NSAttributedString(attributedString: string.value))
            finalString.append(NSAttributedString(string: "\n\n"))
        }
        
        
        let docType: NSAttributedString.DocumentType

        switch exportFormat {
        case .RichTextFormat:
            docType = .rtf
        case .MicrosoftWord:
            docType = .officeOpenXML
        case .PlainText:
            return finalString.string.data(using: .utf8)
        }
        
        let attributes: [NSAttributedString.DocumentAttributeKey: Any] = [.title: "Exported Notes",
                                                                          .documentType: docType,
                                                                          .author: ""]
        
        

        return try finalString.data(from: NSMakeRange(0, finalString.length),
                                    documentAttributes: attributes)
        
    }
}
