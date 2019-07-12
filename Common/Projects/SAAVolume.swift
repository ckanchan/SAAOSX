//
//  SAAVolume.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 27/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

#elseif os(macOS)
import AppKit
typealias UIImage = NSImage
#endif

struct SAAVolume: Hashable {
    var code: String
    var path: String {
        return "saao/\(code)"
    }
    
    var title: String
    var blurb: String
    var image: UIImage
}

extension SAAVolume: Comparable {
    static func < (lhs: SAAVolume, rhs: SAAVolume) -> Bool {
        return lhs.code < rhs.code
    }
}

extension SAAVolume {
    static let saa01 = SAAVolume(code: "saa01",
                                 title: "The Correspondence of Sargon II, Part I: Letters from Assyria and the West",
                                 blurb: "The text editions from the book S. Parpola, The Correspondence of Sargon II, Part I: Letters from Assyria and the West (State Archives of Assyria, 1), 1987 (2015 reprint).",
                                 image: #imageLiteral(resourceName: "saa_01.jpg") )
    
    static let saa02 = SAAVolume(code: "saa02",
                                 title: "Neo-Assyrian Treaties and Loyalty Oaths",
                                 blurb: "The text editions from the book S. Parpola and K. Watanabe, Neo-Assyrian Treaties and Loyalty Oaths (State Archives of Assyria, 2), 1988 (reprint 2014).",
                                 image: #imageLiteral(resourceName: "saa_02.jpg") )
    
    static let saa05 = SAAVolume(code: "saa05",
                                 title: "The Correspondence of Sargon II, Part II: Letters from the Northern and Northeastern Provinces",
                                 blurb: "The text editions from the book G. B. Lanfranchi and S. Parpola, The Correspondence of Sargon II, Part II: Letters from the Northern and Northeastern Provinces (State Archives of Assyria, 5), 1990 (2014 reprint).",
                                 image: #imageLiteral(resourceName: "saa_05.jpg") )
    
    static let saa08 = SAAVolume(code: "saa08",
                                 title: "Astrological Reports to Assyrian Kings",
                                 blurb: "The text editions from the book H. Hunger, Astrological Reports to Assyrian Kings (State Archives of Assyria, 8), 1992 (2014 reprint).",
                                 image: #imageLiteral(resourceName: "saa_08.jpg") )
    
    static let saa10 =  SAAVolume(code: "saa10",
                                  title: "Letters from Assyrian and Babylonian Scholars",
                                  blurb: "The text editions from the book S. Parpola, Letters from Assyrian and Babylonian Scholars (State Archives of Assyria, 10), 1993 (2014 reprint).",
                                  image: #imageLiteral(resourceName: "saa_10.jpg") )
    
    static let saa13 =  SAAVolume(code: "saa13",
                                  title: "Letters from Assyrian and Babylonian Priests to Kings Esarhaddon and Assurbanipal",
                                  blurb: "The text editions from the book S. W. Cole and P. Machinist, Letters from Assyrian and Babylonian Priests to Kings Esarhaddon and Assurbanipal (State Archives of Assyria, 13), 1998 (reprint 2014).",
                                  image: #imageLiteral(resourceName: "saa_13.jpg") )
    
    static let saa15 = SAAVolume(code: "saa15",
                                 title: "The Correspondence of Sargon II, Part III: Letters from Babylonia and the Eastern Provinces",
                                 blurb: "The text editions from the book A. Fuchs and S. Parpola, The Correspondence of Sargon II, Part III: Letters from Babylonia and the Eastern Provinces (State Archives of Assyria, 15), 2001.",
                                 image: #imageLiteral(resourceName: "saa_15.jpg") )
    
    static let saa16 = SAAVolume(code: "saa16",
                                 title: "The Political Correspondence of Esarhaddon",
                                 blurb: "The text editions from the book M. Luukko and G. Van Buylaere, The Political Correspondence of Esarhaddon (State Archives of Assyria, 16), 2002.",
                                 image: #imageLiteral(resourceName: "saa_16.jpg") )
    
    static let saa17 = SAAVolume(code: "saa17",
                                 title: "The Neo-Babylonian Correspondence of Sargon and Sennacherib",
                                 blurb: "The text editions from the book M. Dietrich, The Neo-Babylonian Correspondence of Sargon and Sennacherib (State Archives of Assyria, 17), 2003.",
                                 image: #imageLiteral(resourceName: "saa_17.jpg") )
    
    static let saa18 = SAAVolume(code: "saa18",
                                 title: "The Babylonian Correspondence of Esarhaddon and Letters to Assurbanipal and Sin-šarru-iškun from Northern and Central Babylonia",
                                 blurb: "The text editions from the book F. S. Reynolds, The Babylonian Correspondence of Esarhaddon and Letters to Assurbanipal and Sin-šarru-iškun from Northern and Central Babylonia (State Archives of Assyria, 18), 2003.",
                                 image: #imageLiteral(resourceName: "saa_18.jpg") )
    
    static let saa19 = SAAVolume(code: "saa19",
                                 title: "The Correspondence of Tiglath-Pileser III and Sargon II from Calah/Nimrud",
                                 blurb: "The text editions from the book Mikko Luukko, The Correspondence of Tiglath-Pileser III and Sargon II from Calah/Nimrud (State Archives of Assyria, 19), 2013.",
                                 image: #imageLiteral(resourceName: "saa_19.jpg") )
}

extension SAAVolume {
    init?(path: String) {
        switch path {
        case "saao/saa01": self = .saa01
        case "saao/saa02": self = .saa02
        case "saao/saa05": self = .saa05
        case "saao/saa08": self = .saa08
        case "saao/saa10": self = .saa10
        case "saao/saa13": self = .saa13
        case "saao/saa15": self = .saa15
        case "saao/saa16": self = .saa16
        case "saao/saa17": self = .saa17
        case "saao/saa18": self = .saa18
        case "saao/saa19": self = .saa19
        default: return nil
        }
    }
    
    init?(code: String) {
        switch code {
        case "saa01": self = .saa01
        case "saa02": self = .saa02
        case "saa05": self = .saa05
        case "saa08": self = .saa08
        case "saa10": self = .saa10
        case "saa13": self = .saa13
        case "saa15": self = .saa15
        case "saa16": self = .saa16
        case "saa17": self = .saa17
        case "saa18": self = .saa18
        case "saa19": self = .saa19
        default: return nil
        }
    }
    
    static var allVolumes: [SAAVolume] {
        return [.saa01, .saa02, .saa05, .saa08, .saa10, .saa13, .saa15, .saa16, .saa17, .saa18, .saa19]
    }
}

