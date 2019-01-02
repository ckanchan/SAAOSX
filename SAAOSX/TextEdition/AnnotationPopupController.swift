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
    static func new(textID: TextID, node: NodeReference, transliteration: String, normalisation: String, translation: String, context: String) -> NSWindowController? {
        
        let storyboard = NSStoryboard.init(name: "TextEdition", bundle: Bundle.main)
        guard let window = storyboard.instantiateController(withIdentifier: "AnnotationViewController") as? NSWindowController else {return nil}
        
        
        guard let vc =  window.contentViewController as? AnnotationPopupController else { return nil }

        vc.textID = textID
        vc.nodeReference = node
        vc.annotationMetadata = (transliteration, normalisation, translation)
        vc.context = context
        vc.tagField.delegate = vc


        
        return window
    }
    
    
    lazy var userTagSet: UserTags = {
        return cloudKitDB.userTags
    }()
    
    
    var textID: TextID!
    var nodeReference: NodeReference!
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
        
        // TODO:- Add annotations to cloud store
        cloudKitDB.saveAnnotation(newAnnotation)
        
        // TODO:- Update list of global tags if changed
        if newUserTags != cloudKitDB.userTags {
            cloudKitDB.userTags = newUserTags
        }

        
        view.window?.close()
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
