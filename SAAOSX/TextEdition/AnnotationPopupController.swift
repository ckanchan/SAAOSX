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
    static func new(textID: TextID, node: NodeReference, user: UserManager, transliteration: String, normalisation: String, translation: String, context: String) -> NSWindowController? {
        guard let user = user.user else {return nil}
        
        let storyboard = NSStoryboard.init(name: "TextEdition", bundle: Bundle.main)
        guard let window = storyboard.instantiateController(withIdentifier: "AnnotationViewController") as? NSWindowController else {return nil}
        
        
        guard let vc =  window.contentViewController as? AnnotationPopupController else { return nil }

        vc.textID = textID
        vc.nodeReference = node
        vc.annotationMetadata = (transliteration, normalisation, translation)
        vc.context = context
        vc.tagField.delegate = vc

        
        let annotationManager = FirebaseAnnotationManager(for: user, textID: textID, node: node, delegate: vc)
        let tagManager = FirebaseTagManager(for: user, delegate: vc)
        
        vc.annotationManager = annotationManager
        vc.tagManager = tagManager
        
        return window
    }
    
    
    var annotationManager: FirebaseAnnotationManager! {
        didSet {
            if annotationManager != nil {
                self.textField.isEditable = true
            }
        }
    }
    
    var tagManager: FirebaseTagManager!
    var userTagSet: UserTags = UserTags(tags: [])
    
    
    var textID: TextID!
    var nodeReference: NodeReference!
    var annotationMetadata: (transliteration: String, normalisation: String, translation: String)!

    var context: String? {
        didSet {
            guard let context = self.context else {return}
            self.detailLabel.stringValue = context
        }
    }
    
    var annotation: Note.Annotation? {
        didSet {
            guard let annotation = self.annotation else {return}
            self.textField.stringValue = annotation.annotation
        }
    }

    func annotationDidChange(_ annotation: Note.Annotation) {
        self.annotation = annotation
    }
    
    
    override func viewWillDisappear() {
        self.annotationManager = nil
    }
    
    @IBOutlet weak var detailLabel: NSTextField!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var tagField: NSTokenField!
    
    @IBAction func commit(_ sender: Any) {
        let annotation = textField.stringValue
        guard let reference = nodeReference else {return}
        guard let (transliteration, normalisation, translation) = annotationMetadata else {return}
        let context = self.context ?? ""
        guard let annotationManager = self.annotationManager else {return}
        guard let tagManager = self.tagManager else {return}
        let tokens = tagField.objectValue as? [String] ?? []
        let annotationTags = Set(tokens.map{$0.lowercased()})
        let userTagSet = self.userTagSet.tags.union(annotationTags)
        let newUserTags = UserTags(tags: userTagSet)
        
        DispatchQueue.global().async {
            let newAnnotation = Note.Annotation(nodeReference: reference, transliteration: transliteration, normalisation: normalisation, translation: translation, annotation: annotation, context: context, tags: annotationTags)
            annotationManager.set(annotation: newAnnotation)
            tagManager.set(tags: newUserTags)
            
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
