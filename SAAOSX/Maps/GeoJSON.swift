//
//  GeoJSON.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 22/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation

class GeoJSON: Codable {
    enum GeoJSONType: String, Codable {
        case Point, MultiPoint, LineString, MultiLineString, Polygon, MultiPolygon, GeometryCollection, Feature, FeatureCollection
    }
    
    let type: GeoJSONType
    let boundingBox: [Double]?
    let features: [GeoJSON]?
    
    let geometry: GeoJSON?
    let coordinates: [Double]?
    
    init(type: String, boundingBox: [Double]?, features: [GeoJSON]?, geometry: GeoJSON?, coordinates: [Double]?) {
        self.type = GeoJSONType(rawValue: type)! //This cannot fail
        self.boundingBox = boundingBox
        self.features = features
        self.geometry = geometry
        self.coordinates = coordinates
    }
}

extension GeoJSON {
    enum CodingKeys: String, CodingKey {
        case type, boundingBox = "bbox", features, geometry, coordinates
    }
}

class PleaidesRecord: GeoJSON {
    let title: String
    let description: String
    let representativePoint: (Double, Double)?
    
    init(type: String, boundingBox: [Double]?, features: [GeoJSON]?, geometry: GeoJSON?, coordinates: [Double]?, title: String, description: String, representativePoint: (Double, Double)?) {
        self.title = title
        self.description = description
        self.representativePoint = representativePoint
        super.init(type: type, boundingBox: boundingBox, features: features, geometry: geometry, coordinates: coordinates)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PleiadesCodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        
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

extension PleaidesRecord {
    enum PleiadesCodingKeys: String, CodingKey {
        case title, description, representativePoint = "reprPoint"
    }
}

extension PleaidesRecord: CustomStringConvertible {
}
