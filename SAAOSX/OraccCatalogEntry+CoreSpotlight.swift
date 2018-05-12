//
//  OraccCatalogEntry+CoreSpotlight.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 26/02/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CoreSpotlight
import CDKSwiftOracc

#if os(iOS)
    import MobileCoreServices
#endif

extension OraccCatalogEntry {

    /// Adds the catalogue entry to the system Spotlight database
    func indexItem() {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = self.displayName
        attributeSet.identifier = self.id
        attributeSet.contentDescription = self.title
        attributeSet.displayName = "\(self.displayName)\t\(self.title)"
        attributeSet.theme = self.genre
        attributeSet.contentType = kUTTypeText as String
        attributeSet.kind = "Assyrian letter"

        let item = CSSearchableItem(uniqueIdentifier: self.id, domainIdentifier: "com.ckprivate", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /// Removes the catalogue entry from the system Spotlight database
    func deindexItem() {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [self.id]) {error in
            if let error = error {
                print(error.localizedDescription)
            }

        }
    }
}
