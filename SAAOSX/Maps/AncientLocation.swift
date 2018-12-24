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
    var pleiadesRecord: PleaidesRecord
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init? (for record: PleaidesRecord) {
        self.pleiadesRecord = record
        self.title = record.title
        self.subtitle = record.description
        if let representativePoint = record.representativePoint {
            self.coordinate = CLLocationCoordinate2D(latitude: representativePoint.1, longitude: representativePoint.0)
        } else {
            return nil
        }
    }
    
}
