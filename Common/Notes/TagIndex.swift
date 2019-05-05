//
//  TagIndex.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 05/05/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc

class TagIndex {
    private var userDefaults: UserDefaults = UserDefaults.standard
    
    var index = [Tag: Set<NodeReference>]()
    
    // If a tag no longer has any annotations associated with it, delete the tag
    func overwriteIndex(forTag tag: Tag, withNewSet set: Set<NodeReference>) {
        if set.isEmpty {
            index[tag] = nil
        } else {
            index[tag] = set
        }
    }
    
    @objc func annotationWasAdded(_ notification: Notification) {
        guard let (nodeReference, tags) = notification.annotationMetadata() else {return}
        
        tags.forEach { tag in
            // If the tag is new, create a new set, otherwise update the existing set
            var set = index[tag] ?? Set<NodeReference>()
            set.insert(nodeReference)
            overwriteIndex(forTag: tag, withNewSet: set)
        }
    }
    
    @objc func annotationWasUpdated(_ notification: Notification) {
        guard let (nodeReference, newTags) = notification.annotationMetadata() else {return}
        
        // Iterate through each tag to see if this annotation is mentioned in it
        index.forEach({(tag, referenceSet) in
            if referenceSet.contains(nodeReference) {
                // If the annotation is present, check the tag still applies, otherwise delete the annotation from the tag list
                if newTags.contains(tag) { return } else {
                    var updatedSet = referenceSet
                    updatedSet.remove(nodeReference)
                    overwriteIndex(forTag: tag, withNewSet: updatedSet)
                }
            }
        })
    }
    
    @objc func annotationWasDeleted(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: NodeReference],
            let nodeReference = userInfo["nodeReference"] else {return}
        
        index.forEach({(tag, referenceSet) in
            if referenceSet.contains(nodeReference) {
                var updatedSet = referenceSet
                updatedSet.remove(nodeReference)
                overwriteIndex(forTag: tag, withNewSet: referenceSet)
            } else {
                return
            }
        })
    }
    
    
}

extension TagIndex {
    static var userTagKey: String {
        return "userTags"
    }
    
    static var userTagCKRecordSystemFields: String {
        return "userTagsCKRecordSystemFields"
    }
}
