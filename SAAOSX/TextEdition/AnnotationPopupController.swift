//
//  AnnotationPopupController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 20/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc

class AnnotationPopupController: NSViewController {
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
        let newTags = UserTags(tags: annotationTags)
        
        let newAnnotation = Annotation(nodeReference: reference, transliteration: transliteration, normalisation: normalisation, translation: translation, annotation: annotation, context: context, tags: annotationTags)
        
        if notesDB.retrieveSingleAnnotation(nodeReference) != nil {
            notesDB.updateAnnotation(newAnnotation)
        } else {
            notesDB.createAnnotation(newAnnotation)
        }
        
        userTags.updateTags(adding: newTags)
        view.window?.close()
    }
    
    @objc func annotationDidChange(_ notification: Notification) {
        if let annotation = notesDB.retrieveSingleAnnotation(nodeReference) {
            self.annotation = annotation
        } else {
            self.annotation?.annotation = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(annotationDidChange),
                                               name: .annotationAdded,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(annotationDidChange),
                                               name: .annotationDeleted,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(annotationDidChange),
                                               name: .annotationUpdated,
                                               object: nil)
    }
}

extension AnnotationPopupController {
    static func new(textID: TextID,
                    node: NodeReference,
                    transliteration: String,
                    normalisation: String,
                    translation: String,
                    context: String) -> NSWindowController? {
        let storyboard = NSStoryboard(name: "TextEdition", bundle: Bundle.main)
        guard let window = storyboard.instantiateController(withIdentifier: "AnnotationViewController") as? NSWindowController else {return nil}
        guard let vc =  window.contentViewController as? AnnotationPopupController else { return nil }
        vc.textID = textID
        vc.nodeReference = node
        vc.annotationMetadata = (transliteration, normalisation, translation)
        vc.context = context
        vc.tagField.delegate = vc
        return window
    }
    
    static func new(withAnnotation annotation: Annotation) -> NSWindowController? {
        guard let windowController = AnnotationPopupController.new(textID: annotation.nodeReference.base,
                                                                   node: annotation.nodeReference,
                                                                   transliteration: annotation.transliteration,
                                                                   normalisation: annotation.normalisation,
                                                                   translation: annotation.translation,
                                                                   context: annotation.context),
            let annotationViewController = windowController.contentViewController as? AnnotationPopupController else {return nil}
        annotationViewController.annotation = annotation
        return windowController
    }
}

extension AnnotationPopupController: NSTokenFieldDelegate {
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        return userTags.userTags.tags.filter{$0.lowercased().contains(substring.lowercased())}
    }
}
