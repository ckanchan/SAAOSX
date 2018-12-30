//
//  TextEditionStringContainer+MapFunctions.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 30/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc

extension TextEditionStringContainer {
    func getLocationNamesInText() -> [String]? {
        var ancientLocationIDs = [String]()
        let normalisationRange = NSMakeRange(0, self.normalisation.length)
        self.normalisation.enumerateAttribute(.partOfSpeech, in: normalisationRange, options: .longestEffectiveRangeNotRequired, using: {value, range, _ in
            
            guard let partOfSpeech = value as? String else {return}
            guard partOfSpeech == "GN" else {return}
            
            let substr = normalisation.attributedSubstring(from: range)
            
            let attrs = substr.attributes(at: 0, effectiveRange: nil)
            
            guard let citationForm = attrs[.oraccCitationForm] as? String else {return}
            
            ancientLocationIDs.append(citationForm)
        })
        if !ancientLocationIDs.isEmpty {
            return ancientLocationIDs
        } else {
            return nil
        }
    }
}
