//
//  AncientMap.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 28/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import MapKit

class AncientMap {
    private var locationDictionary: [String: AncientLocation]
    
    var siteCount: Int {
        return locationDictionary.count
    }
    
    var locations: [AncientLocation] {
        return Array(locationDictionary.values)
    }
    
    func getLocationAtIndex(_ index: Int) -> (String, AncientLocation)? {
        guard index < siteCount else {return nil}
        let startIndex = locationDictionary.startIndex
        let returnIndex = locationDictionary.index(startIndex, offsetBy: index)
        let value = locationDictionary[returnIndex]
        return value
        
    }
    
    func getLocationForQpnID(_ qpnID: String) -> AncientLocation? {
        return locationDictionary[qpnID]
    }
    
    func getPleiadesPlaces(then callback: @escaping ([String: AncientLocation]) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {return}
            strongSelf.locationDictionary.values.forEach {
                _ = $0.getPleiadesRecord()
            }
            DispatchQueue.main.async {
                callback(strongSelf.locationDictionary)
            }
        }
    }
    
    init(locationDictionary: [String: AncientLocation]) {
        self.locationDictionary = locationDictionary
    }
}
