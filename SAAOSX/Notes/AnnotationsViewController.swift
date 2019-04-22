//
//  AnnotationsViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 26/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc

class AnnotationsViewController: NSViewController {
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var annotationView: NSCollectionView! {
        didSet {
            annotationView.dataSource = self
        }
    }
    
    var annotations: [Annotation]? = nil {
        didSet {
            if self.annotations != nil {
                annotationView.reloadData()
            }
        }
    }
    
    var textID: TextID?
}

extension AnnotationsViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if let annotations = self.annotations {
            return annotations.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "AnnotationItem"), for: indexPath)
        
        if let annotations = self.annotations {
            guard let annotationView = item as? AnnotationItem else {return item}
            let annotation = annotations[indexPath.item]
            annotationView.annotation = annotation
            
            if let info = sqlite?.getEntryFor(id: annotation.nodeReference.base) {
                annotationView.catalogueInfo = info
            }
            
            return item
        } else {
            return item
        }
    }
}
