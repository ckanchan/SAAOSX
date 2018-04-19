//
//  TextEditionStringContainer.swift
//  CDKOraccControllers
//
//  Created by Chaitanya Kanchan on 23/02/2018.
//

import Foundation
import OraccJSONtoSwift

#if os(macOS)
    import AppKit.NSFont
#elseif os(iOS)
    import UIKit.UIFont
#endif

public class TextEditionStringContainer: NSCoding {
    
    public lazy var cuneiform: String = {
        return self.textEdition?.cuneiform ?? "No edition available"
    }()
    
    public lazy var transliteration: NSAttributedString = {
        
        #if os(macOS)
        return self.textEdition?.formattedTransliteration(withFont: NSFont.systemFont(ofSize: NSFont.systemFontSize)) ?? NSAttributedString(string: "No edition available")
        #elseif os(iOS)
            return self.textEdition?.formattedTransliteration(withFont: UIFont.systemFont(ofSize: UIFont.systemFontSize)) ?? NSAttributedString(string: "No edition available")
        #endif
    }()
    
    public lazy var normalisation: NSAttributedString = {
        #if os(macOS)
            return self.textEdition?.formattedNormalisation(withFont: NSFont.systemFont(ofSize: NSFont.systemFontSize)) ?? NSAttributedString(string: "No edition available")
        #elseif os(iOS)
            return self.textEdition?.formattedNormalisation(withFont: UIFont.systemFont(ofSize: UIFont.systemFontSize)) ?? NSAttributedString(string: "No edition available")
        #endif
    }()
    
    public lazy var translation: String = {
        #if os(macOS)
            return self.textEdition?.scrapeTranslation ?? self.textEdition?.literalTranslation ?? "No translation available"
        #elseif os(iOS)
            return self.textEdition?.literalTranslation ?? "No translation available"
        #endif
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
    
    
//    public func encode(to encoder: Encoder) throws {
//
//        let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.html]
//
//        let transliterationData = try self.transliteration.data(from: NSMakeRange(0, self.transliteration.length), documentAttributes: documentAttributes)
//        let transliterationString = String(data: transliterationData, encoding: .utf8)
//        let normalisationData = try self.normalisation.data(from: NSMakeRange(0, normalisation.length), documentAttributes: documentAttributes)
//        let normalisationString = String(data: normalisationData, encoding: .utf8)
//
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.cuneiform, forKey: .cuneiform)
//        try container.encode(self.translation, forKey: .translation)
//        try container.encode(transliterationString, forKey: .transliteration)
//        try container.encode(normalisationString, forKey: .normalisation)
//    }
//
//    required public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let cuneiform = try container.decode(String.self, forKey: .cuneiform)
//        let translation = try container.decode(String.self, forKey: .translation)
//
//        let transliterationData = try container.decode(String.self, forKey: .transliteration)
//        let normalisationData = try container.decode(String.self, forKey: .normalisation)
//
//        let transliteration = NSAttributedString(html: transliterationData.data(using: .utf8)!, options: [:], documentAttributes: nil)
//        let normalisation = NSAttributedString(html: normalisationData.data(using: .utf8)!, options: [:], documentAttributes: nil)
//
//        self.cuneiform = cuneiform
//        self.translation = translation
//        self.transliteration = transliteration ?? NSAttributedString(string: "No text found")
//        self.normalisation = normalisation ?? NSAttributedString(string: "No text found")
//    }
//
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
}

enum TextEditionEncodingError: Error {
    case noTextEdition
}
