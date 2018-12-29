//
//  AncientLocation.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 23/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import MapKit
import CDKSwiftOracc

class AncientLocation: NSObject, MKAnnotation {
    private(set) var pleiadesRecord: PleiadesRecord?
    
    private(set) var pleiadesID: Int?
    private(set) var title: String?
    private(set) var subtitle: String?
    private(set) var coordinate: CLLocationCoordinate2D
    
    func getPleiadesRecord() -> PleiadesRecord? {
        guard let id = self.pleiadesID else {return nil}
        if let record = self.pleiadesRecord {
            return record
        } else {
            if let record = PleiadesRecord.lookupInPleiades(id: id) {
                self.pleiadesRecord = record
                self.title = record.title
                self.subtitle = record.description
                return record
            } else {
                return nil
            }
        }
    }
    
    init(latitude: Double, longitude: Double, title: String, subtitle: String) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = title
        self.subtitle = subtitle
    }
    
    init (latitude: Double, longitude: Double, pleiadesID: Int) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.pleiadesID = pleiadesID
    }
    
    public static func getListOfPlaces(from url: URL) -> [String: AncientLocation]? {
        
        struct DecodedData: Decodable {
            let oraccGlossaryId: String
            let akkadian: String
            let pleiadesId: String?
            let latitude: String?
            let longitude: String?
        }
        
        guard let data = try? Data(contentsOf: url) else {return nil}
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let references = try? decoder.decode([DecodedData].self, from: data) else {return nil}
        
        var placeDictionary = [String: AncientLocation]()
        references.forEach {reference in
            guard let latitudeStr = reference.latitude,
                let longitudeStr = reference.longitude else {return}
            
            guard let latitude = Double(latitudeStr),
                let longitude = Double(longitudeStr) else {return}
            if let pleiadesIDStr = reference.pleiadesId {
                if let pleiadesID = Int(pleiadesIDStr) {
                    let ancientLocation = AncientLocation(latitude: latitude, longitude: longitude, pleiadesID: pleiadesID)
                    placeDictionary[reference.oraccGlossaryId] = ancientLocation
                } else {
                    let ancientLocation = AncientLocation(latitude: latitude, longitude: longitude, title: reference.akkadian, subtitle: "")
                    placeDictionary[reference.oraccGlossaryId] = ancientLocation
                }
            } else {
                let ancientLocation = AncientLocation(latitude: latitude, longitude: longitude, title: reference.akkadian, subtitle: "")
                placeDictionary[reference.oraccGlossaryId] = ancientLocation
            }
        }
        return placeDictionary
    }
    
}
