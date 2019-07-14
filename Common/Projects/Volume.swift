//
//  Volume.swift
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

struct Volume: Hashable {
    enum Project: String { case cams, rinap, riao, saa }
    var project: Project
    var code: String
    var path: String { return "\(project.rawValue)/\(code)" }
    
    var title: String
    var blurb: String
    var image: UIImage
}

extension Volume: Comparable {
    static func < (lhs: Volume, rhs: Volume) -> Bool {
        return lhs.code < rhs.code
    }
}

extension Volume {
    init?(path: String) {
        switch path {
        case "cams/anzu": self = .anzu
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
        case "rinap/rinap1": self = .rinap1
        case "rinap/rinap3": self = .rinap3
        case "rinap/rinap4": self = .rinap4
        case "riao/riao": self = .riao
        default: return nil
        }
    }
    
    init?(code: String) {
        switch code {
        case "anzu": self = .anzu
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
        case "rinap1": self = .rinap1
        case "rinap3": self = .rinap3
        case "rinap4": self = .rinap4
        case "riao": self = .riao
        default: return nil
        }
    }
    
    static var allVolumes: [Volume] {
        return [anzu]
            + rinapVolumes
            + [riao]
            + saaVolumes
    }
}

