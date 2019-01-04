//
//  AnnotationPopupController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 20/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc

class AnnotationPopupController: NSViewController, SingleAnnotationDisplaying {
    lazy var userTagSet: UserTags = {
        return cloudKitDB.userTags
    }()
    
    
    var textID: TextID!
    var nodeReference: NodeReference!
    var annotationManager: TextAnnotationManager!
    var annotationMetadata: (transliteration: String, normalisation: String, translation: String)!

    var context: String? {
        didSet {
            guard let context = self.context else {return}
            self.detailLabel.stringValue = context
        }
    }
    
    var annotation: Annotation? {
        didSet {
            guard let annotation = self.annotation else {return}
            self.textField.stringValue = annotation.annotation
        }
    }

    func annotationDidChange(_ annotation: Annotation) {
        self.annotation = annotation
    }
    
    
    @IBOutlet weak var detailLabel: NSTextField!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var tagField: NSTokenField!
    
    @IBAction func commit(_ sender: Any) {
        let annotation = textField.stringValue
        guard let reference = nodeReference else {return}
        guard let (transliteration, normalisation, translation) = annotationMetadata else {return}
        let context = self.context ?? ""
        let tokens = tagField.objectValue as? [String] ?? []
        let annotationTags = Set(tokens.map{$0.lowercased()})
        let userTagSet = self.userTagSet.tags.union(annotationTags)
        let newUserTags = UserTags(tags: userTagSet)
        
        
        let newAnnotation = Annotation(nodeReference: reference, transliteration: transliteration, normalisation: normalisation, translation: translation, annotation: annotation, context: context, tags: annotationTags)
        
        annotationManager.updateAnnotation(newAnnotation)
        
        if newUserTags != cloudKitDB.userTags {
            cloudKitDB.userTags = newUserTags
        }
        
        view.window?.close()
    }
}

extension AnnotationPopupController {
    static func new(textID: TextID, node: NodeReference, transliteration: String, normalisation: String, translation: String, context: String, annotationManager: TextAnnotationManager) -> NSWindowController? {
        let storyboard = NSStoryboard(name: "TextEdition", bundle: Bundle.main)
        guard let window = storyboard.instantiateController(withIdentifier: "AnnotationViewController") as? NSWindowController else {return nil}
        guard let vc =  window.contentViewController as? AnnotationPopupController else { return nil }
        vc.textID = textID
        vc.nodeReference = node
        vc.annotationMetadata = (transliteration, normalisation, translation)
        vc.context = context
        vc.tagField.delegate = vc
        vc.annotationManager = annotationManager
        return window
    }
    
    static func new(withAnnotation annotation: Annotation, annotationManager: TextAnnotationManager) -> NSWindowController? {
        guard let windowController = AnnotationPopupController.new(textID: annotation.nodeReference.base, node: annotation.nodeReference, transliteration: annotation.transliteration, normalisation: annotation.normalisation, translation: annotation.translation, context: annotation.context, annotationManager: annotationManager),
            let annotationViewController = windowController.contentViewController as? AnnotationPopupController else {return nil}
        annotationViewController.annotation = annotation
        return windowController
    }
}

extension AnnotationPopupController: TagDisplaying {
    func tagsDidChange(_ tags: UserTags) {
        self.userTagSet = tags
    }
}

extension AnnotationPopupController: NSTokenFieldDelegate {
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        return userTagSet.tags.filter{$0.lowercased().contains(substring.lowercased())}
    }
}
