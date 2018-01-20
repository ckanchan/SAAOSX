//
//  TextEditionStringContainer.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 20/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift

class TextEditionStringContainer {
    lazy var cuneiform: String = {
        return self.textEdition?.cuneiform ?? "No edition availabe"
    }()
    
    lazy var transliteration: NSAttributedString = {
        return self.textEdition?.formattedTransliteration(withFont: NSFont.systemFont(ofSize: NSFont.systemFontSize)) ?? NSAttributedString(string: "No edition available")
    }()
    
    lazy var normalisation: NSAttributedString = {
        return self.textEdition?.formattedNormalisation(withFont: NSFont.systemFont(ofSize: NSFont.systemFontSize)) ?? NSAttributedString(string: "No edition available")
    }()
    
    lazy var translation: String = {
        return self.textEdition?.scrapeTranslation ?? self.textEdition?.literalTranslation ?? "No translation available"
    }()
    
    var textEdition: OraccTextEdition? = nil
    
    init(_ edition: OraccTextEdition) {
        self.textEdition = edition
    }
}
