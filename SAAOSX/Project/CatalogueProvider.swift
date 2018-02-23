//
//  CatalogueProvider.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 19/02/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import OraccJSONtoSwift

protocol CatalogueProvider: AnyObject {
    var texts: [OraccCatalogEntry] { get }
    var name: String { get }
    
}
