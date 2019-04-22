////
////  TextAnnotationManager.swift
////  SAAOSX
////
////  Created by Chaitanya Kanchan on 04/01/2019.
////  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
////
//
//import Foundation
//import CDKSwiftOracc
//
//final class TextAnnotationManager {
//    let notesDB: NoteSQLDatabase
//    let textID: TextID
//    weak var annotationDelegate: AnnotationsDisplaying?
//    var userTagController: UserTagController
//    var annotations: [NodeReference: Annotation] = [:]
//
//    func annotationForReference(_ reference: String) -> Annotation? {
//        let nodeReference = NodeReference(stringLiteral: reference)
//        return annotations[nodeReference]
//    }
//
//    func updateAnnotations() {
//        let annotations = notesDB.retrieveAnnotations(forID: textID)
//        annotations.forEach { annotation in
//            self.annotations[annotation.nodeReference] = annotation
//        }
//        self.annotationDelegate?.annotationsWereUpdated()
//    }
//
//    func updateAnnotation(_ annotation: Annotation) {
//        if annotations[annotation.nodeReference] == nil {
//            notesDB.createAnnotation(annotation)
//        } else {
//            notesDB.updateAnnotation(annotation)
//        }
//        self.annotations[annotation.nodeReference] = annotation
//    }
//
//    init(notesDB: NoteSQLDatabase, textID: TextID, userTagController: UserTagController, annotationDelegate: AnnotationsDisplaying? = nil) {
//        self.notesDB = notesDB
//        self.userTagController = userTagController
//        self.textID = textID
//        self.annotationDelegate = annotationDelegate
//        self.updateAnnotations()
//    }
//}
