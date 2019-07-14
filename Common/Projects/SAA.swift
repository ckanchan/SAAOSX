//
//  SAA.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 14/07/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation

extension Volume {
    static let saa01 = Volume(project: .saa,
                              code: "saa01",
                              title: "The Correspondence of Sargon II, Part I: Letters from Assyria and the West",
                              blurb: "The text editions from the book S. Parpola, The Correspondence of Sargon II, Part I: Letters from Assyria and the West (State Archives of Assyria, 1), 1987 (2015 reprint).",
                              image: #imageLiteral(resourceName: "saa_01.jpg") )
    
    static let saa02 = Volume(project: .saa,
                              code: "saa02",
                              title: "Neo-Assyrian Treaties and Loyalty Oaths",
                              blurb: "The text editions from the book S. Parpola and K. Watanabe, Neo-Assyrian Treaties and Loyalty Oaths (State Archives of Assyria, 2), 1988 (reprint 2014).",
                              image: #imageLiteral(resourceName: "saa_02.jpg") )
    
    static let saa05 = Volume(project: .saa,
                              code: "saa05",
                              title: "The Correspondence of Sargon II, Part II: Letters from the Northern and Northeastern Provinces",
                              blurb: "The text editions from the book G. B. Lanfranchi and S. Parpola, The Correspondence of Sargon II, Part II: Letters from the Northern and Northeastern Provinces (State Archives of Assyria, 5), 1990 (2014 reprint).",
                              image: #imageLiteral(resourceName: "saa_05.jpg") )
    
    static let saa08 = Volume(project: .saa,
                              code: "saa08",
                              title: "Astrological Reports to Assyrian Kings",
                              blurb: "The text editions from the book H. Hunger, Astrological Reports to Assyrian Kings (State Archives of Assyria, 8), 1992 (2014 reprint).",
                              image: #imageLiteral(resourceName: "saa_08.jpg") )
    
    static let saa10 =  Volume(project: .saa,
                               code: "saa10",
                               title: "Letters from Assyrian and Babylonian Scholars",
                               blurb: "The text editions from the book S. Parpola, Letters from Assyrian and Babylonian Scholars (State Archives of Assyria, 10), 1993 (2014 reprint).",
                               image: #imageLiteral(resourceName: "saa_10.jpg") )
    
    static let saa13 =  Volume(project: .saa,
                               code: "saa13",
                               title: "Letters from Assyrian and Babylonian Priests to Kings Esarhaddon and Assurbanipal",
                               blurb: "The text editions from the book S. W. Cole and P. Machinist, Letters from Assyrian and Babylonian Priests to Kings Esarhaddon and Assurbanipal (State Archives of Assyria, 13), 1998 (reprint 2014).",
                               image: #imageLiteral(resourceName: "saa_13.jpg") )
    
    static let saa15 = Volume(project: .saa,
                              code: "saa15",
                              title: "The Correspondence of Sargon II, Part III: Letters from Babylonia and the Eastern Provinces",
                              blurb: "The text editions from the book A. Fuchs and S. Parpola, The Correspondence of Sargon II, Part III: Letters from Babylonia and the Eastern Provinces (State Archives of Assyria, 15), 2001.",
                              image: #imageLiteral(resourceName: "saa_15.jpg") )
    
    static let saa16 = Volume(project: .saa,
                              code: "saa16",
                              title: "The Political Correspondence of Esarhaddon",
                              blurb: "The text editions from the book M. Luukko and G. Van Buylaere, The Political Correspondence of Esarhaddon (State Archives of Assyria, 16), 2002.",
                              image: #imageLiteral(resourceName: "saa_16.jpg") )
    
    static let saa17 = Volume(project: .saa,
                              code: "saa17",
                              title: "The Neo-Babylonian Correspondence of Sargon and Sennacherib",
                              blurb: "The text editions from the book M. Dietrich, The Neo-Babylonian Correspondence of Sargon and Sennacherib (State Archives of Assyria, 17), 2003.",
                              image: #imageLiteral(resourceName: "saa_17.jpg") )
    
    static let saa18 = Volume(project: .saa,
                              code: "saa18",
                              title: "The Babylonian Correspondence of Esarhaddon and Letters to Assurbanipal and Sin-šarru-iškun from Northern and Central Babylonia",
                              blurb: "The text editions from the book F. S. Reynolds, The Babylonian Correspondence of Esarhaddon and Letters to Assurbanipal and Sin-šarru-iškun from Northern and Central Babylonia (State Archives of Assyria, 18), 2003.",
                              image: #imageLiteral(resourceName: "saa_18.jpg") )
    
    static let saa19 = Volume(project: .saa,
                              code: "saa19",
                              title: "The Correspondence of Tiglath-Pileser III and Sargon II from Calah/Nimrud",
                              blurb: "The text editions from the book Mikko Luukko, The Correspondence of Tiglath-Pileser III and Sargon II from Calah/Nimrud (State Archives of Assyria, 19), 2013.",
                              image: #imageLiteral(resourceName: "saa_19.jpg") )
    
    static var saaVolumes: [Volume] {
        return [.saa01, .saa02, .saa05, .saa08, .saa10, .saa13, .saa15, .saa16, .saa17, .saa18, .saa19]
    }
}
