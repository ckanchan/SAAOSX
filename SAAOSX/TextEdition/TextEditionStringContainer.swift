//
//  TextEditionStringContainer.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 20/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift

class TextEditionStringContainer: Codable, NSCoding {
    
    lazy var cuneiform: String = {
        return self.textEdition?.cuneiform ?? "No edition available"
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
    
    private init(cuneiform: String, transliteration: NSAttributedString, normalisation: NSAttributedString, translation: String){
        self.cuneiform = cuneiform
        self.transliteration = transliteration
        self.normalisation = normalisation
        self.translation = translation
    }
    
    
    enum CodingKeys: String, CodingKey {
        case cuneiform, transliteration, normalisation, translation
    }
    
    
    public func encode(to encoder: Encoder) throws {
        
        let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.html]
        
        let transliterationData = try self.transliteration.data(from: NSMakeRange(0, self.transliteration.length), documentAttributes: documentAttributes)
        let transliterationString = String(data: transliterationData, encoding: .utf8)
        let normalisationData = try self.normalisation.data(from: NSMakeRange(0, normalisation.length), documentAttributes: documentAttributes)
        let normalisationString = String(data: normalisationData, encoding: .utf8)
        
        

        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.cuneiform, forKey: .cuneiform)
        try container.encode(self.translation, forKey: .translation)
        try container.encode(transliterationString, forKey: .transliteration)
        try container.encode(normalisationString, forKey: .normalisation)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let cuneiform = try container.decode(String.self, forKey: .cuneiform)
        let translation = try container.decode(String.self, forKey: .translation)
        
        let transliterationData = try container.decode(String.self, forKey: .transliteration)
        let normalisationData = try container.decode(String.self, forKey: .normalisation)
        
        let transliteration = NSAttributedString(html: transliterationData.data(using: .utf8)!, options: [:], documentAttributes: nil)
        let normalisation = NSAttributedString(html: normalisationData.data(using: .utf8)!, options: [:], documentAttributes: nil)
        
        self.cuneiform = cuneiform
        self.translation = translation
        self.transliteration = transliteration ?? NSAttributedString(string: "No text found")
        self.normalisation = normalisation ?? NSAttributedString(string: "No text found")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(cuneiform, forKey: "cuneiform")
        aCoder.encode(transliteration, forKey: "transliteration")
        aCoder.encode(normalisation, forKey: "normalisation")
        aCoder.encode(translation, forKey: "translation")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let cuneiform = aDecoder.decodeObject(forKey: "cuneiform") as? String,
            let transliteration = aDecoder.decodeObject(forKey: "transliteration") as? NSAttributedString,
            let normalisation = aDecoder.decodeObject(forKey: "normalisation") as? NSAttributedString,
            let translation = aDecoder.decodeObject(forKey: "translation") as? String else {return nil}
        
        self.init(cuneiform: cuneiform, transliteration: transliteration, normalisation: normalisation, translation: translation)
    }
}

enum TextEditionEncodingError: Error {
    case noTextEdition
}
