//
//  OraccCatalogEntry+Hashable.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 15/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import CDKSwiftOracc


extension OraccCatalogEntry: Hashable, Equatable {
    public static func == (lhs: OraccCatalogEntry, rhs: OraccCatalogEntry) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
