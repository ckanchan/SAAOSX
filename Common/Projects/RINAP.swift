//
//  RINAPVolume.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 14/07/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

#elseif os(macOS)
import AppKit
typealias UIImage = NSImage
#endif

extension Volume {
    static let rinap1 = Volume(project: .rinap,
                               code: "rinap1",
                               title: "Tiglath-pileser III and Shalmaneser V",
                               blurb: "The official inscriptions of Tiglath-pileser III (744-727 BC) and Shalmaneser V (726-722 BC), kings of Assyria, edited by Hayim Tadmor and Shigeo Yamada.",
                               image: #imageLiteral(resourceName: "rinap1.jpg"))
    
    static let rinap3 = Volume(project: .rinap,
                               code: "rinap3",
                               title: "Sennacherib",
                               blurb: "The official inscriptions of Sennacherib (704-681 BC), king of Assyria, edited by A. Kirk Grayson and Jamie Novotny.",
                               image: #imageLiteral(resourceName: "rinap3.jpg"))
    
    static let rinap4 = Volume(project: .rinap,
                               code: "rinap4",
                               title: "Esarhaddon",
                               blurb: "The official inscriptions of Esarhaddon, king of Assyria (680-669 BC), edited by Erle Leichty.",
                               image: #imageLiteral(resourceName: "rinap4.jpg"))
    
    static let riao = Volume(project: .rinap,
                             code: "riao",
                             title: "Royal Inscriptions of Assyria online",
                             blurb: "This project intends to present annotated editions of the entire corpus of Assyrian royal inscriptions, texts that were published in RIMA 1-3 and RINAP 1 and 3-4. This rich, open-access corpus has been made available through the kind permission of Kirk Grayson and Grant Frame and with funding provided by the Alexander von Humboldt Foundation.\nRIAo is based at LMU Munich (Historisches Seminar, Alte Geschichte) and is managed by Jamie Novotny and Karen Radner. Kirk Grayson, Nathan Morello, and Jamie Novotny are the primary content contributors.",
                             image: #imageLiteral(resourceName: "riao.jpg"))
    
    static var rinapVolumes: [Volume] {
        return [.rinap1, .rinap3, .rinap4]
    }
}
