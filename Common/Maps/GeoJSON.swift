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
