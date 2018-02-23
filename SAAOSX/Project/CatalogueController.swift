//
//  CatalogueController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 23/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import OraccJSONtoSwift

class CatalogueController: CatalogueProvider {
    enum CatalogueSource {
        case local, interface, pins
    }
    
    let catalogue: OraccCatalog
    let texts: [OraccCatalogEntry]
    let source: CatalogueSource
    
    
    lazy var name = {return self.catalogue.project}()
    init(catalogue: OraccCatalog, sorted: [OraccCatalogEntry], source: CatalogueSource) {
        self.catalogue = catalogue
        self.texts = sorted
        self.source = source
    }
}


