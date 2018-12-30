//
//  CLLocationCoordinate2D+Equatable.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 30/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import CoreLocation.CLLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        if (lhs.latitude == rhs.latitude) && (lhs.longitude == rhs.longitude) {
            return true
        } else {
            return false
        }
    }
}
