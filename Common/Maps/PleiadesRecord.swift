//
//  PleiadesRecord.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 29/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation

final class PleiadesRecord: GeoJSON {
    let title: String
    let description: String
    let representativePoint: (Double, Double)?
    let rights: String
    
    init(type: String, boundingBox: [Double]?, features: [GeoJSON]?, geometry: GeoJSON?, coordinates: [Double]?, title: String, description: String, representativePoint: (Double, Double)?, rights: String) {
        self.title = title
        self.description = description
        self.representativePoint = representativePoint
        self.rights = rights
        super.init(type: type, boundingBox: boundingBox, features: features, geometry: geometry, coordinates: coordinates)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PleiadesCodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.rights = try container.decode(String.self, forKey: .rights)
        
        if let representativePointArray = try container.decodeIfPresent([Double].self, forKey: .representativePoint) {
            if representativePointArray.count == 2 {
                self.representativePoint = (representativePointArray[0], representativePointArray[1])
            } else {
                self.representativePoint = nil
            }
        } else {
            self.representativePoint = nil
        }
        
        try super.init(from: decoder)
    }
}

extension PleiadesRecord {
    enum PleiadesCodingKeys: String, CodingKey {
        case title, description, representativePoint = "reprPoint", rights
    }
}

extension PleiadesRecord {
    static func lookupInPleiades(id: Int) -> PleiadesRecord? {
        guard let url = URL(string: "https://pleiades.stoa.org/places/\(id)/json") else {return nil}
        guard let data = try? Data.init(contentsOf: url) else {return nil}
        let decoder = JSONDecoder()
        guard let geoJSON = try? decoder.decode(PleiadesRecord.self, from: data) else {return nil}
        return geoJSON
    }
}
