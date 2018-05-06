//
//  TextEditionStringContainer.swift
//  CDKOraccControllers
//
//  Created by Chaitanya Kanchan on 23/02/2018.
//

import Foundation
import CDKSwiftOracc


/// A class that caches the strings of an `OraccTextEdition`
public class TextEditionStringContainer: NSCoding {
    
    public lazy var cuneiform: String = {
        return self.textEdition?.cuneiform ?? "No edition available"
    }()
    
    public lazy var transliteration: NSAttributedString = {
        return self.textEdition?.transliterated() ?? NSAttributedString(string: "No edition available")
    }()
    
    public lazy var normalisation: NSAttributedString = {
        return self.textEdition?.normalised() ?? NSAttributedString(string: "No edition available")
    }()
    
    public lazy var translation: String = {
        return self.textEdition?.scrapeTranslation() ?? self.textEdition?.literalTranslation ?? "No translation available"
    }()
    
    public var textEdition: OraccTextEdition? = nil
    
    public init(_ edition: OraccTextEdition) {
        self.textEdition = edition
    }
    
    public init(cuneiform: String, transliteration: NSAttributedString, normalisation: NSAttributedString, translation: String){
        self.cuneiform = cuneiform
        self.transliteration = transliteration
        self.normalisation = normalisation
        self.translation = translation
    }
    
    
    enum CodingKeys: String, CodingKey {
        case cuneiform, transliteration, normalisation, translation
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(cuneiform, forKey: "cuneiform")
        aCoder.encode(transliteration, forKey: "transliteration")
        aCoder.encode(normalisation, forKey: "normalisation")
        aCoder.encode(translation, forKey: "translation")
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        guard let cuneiform = aDecoder.decodeObject(forKey: "cuneiform") as? String,
            let transliteration = aDecoder.decodeObject(forKey: "transliteration") as? NSAttributedString,
            let normalisation = aDecoder.decodeObject(forKey: "normalisation") as? NSAttributedString,
            let translation = aDecoder.decodeObject(forKey: "translation") as? String else {return nil}
        
        self.init(cuneiform: cuneiform, transliteration: transliteration, normalisation: normalisation, translation: translation)
    }
    
    public func render(withPreferences prefs: OraccTextEdition.FormattingPreferences) {
        self.transliteration = self.transliteration.render(withPreferences: prefs)
        self.normalisation = self.normalisation.render(withPreferences: prefs)
    }
}

enum TextEditionEncodingError: Error {
    case noTextEdition
}


