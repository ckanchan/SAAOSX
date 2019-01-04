//
//  TextAnnotationManager.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 04/01/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc
import CloudKit

class TextAnnotationManager {
    let cloudKitDB: CloudKitNotes
    let textID: TextID
    var annotationDelegate: AnnotationsDisplaying?
    var userTagSet: UserTags
    var annotations: [NodeReference: Annotation] = [:]
    
    func annotationForReference(_ reference: String) -> Annotation? {
        let nodeReference = NodeReference(stringLiteral: reference)
        return annotations[nodeReference]
    }
    
    func updateAnnotations() {
        var annotations = [Annotation]()
        cloudKitDB.retrieveAnnotations(
            forTextID: textID,
            forRetrievedAnnotation: {annotations.append($0)},
            onCompletion: {[weak self] _ in
                annotations.forEach { annotation in
                    self?.annotations[annotation.nodeReference] = annotation
                    self?.annotationDelegate?.annotationsWereUpdated()
                }
        })
    }
    
    func updateAnnotation(_ annotation: Annotation) {
        self.annotations[annotation.nodeReference] = annotation
        cloudKitDB.saveAnnotation(annotation)
    }
    
    init(cloudKitDB: CloudKitNotes, textID: TextID, annotationDelegate: AnnotationsDisplaying? = nil) {
        self.cloudKitDB = cloudKitDB
        self.userTagSet = cloudKitDB.userTags
        self.textID = textID
        self.annotationDelegate = annotationDelegate
        self.updateAnnotations()
    }
}
