//
//  TextEditionStringContainer.swift
//  CDKOraccControllers
//
//  Created by Chaitanya Kanchan on 23/02/2018.
//

import Foundation
import CDKSwiftOracc

/// A class that caches the strings of an `OraccTextEdition`
final public class TextEditionStringContainer: NSCoding {

    public lazy var cuneiform: String = {
        return self.textEdition?.cuneiform ?? "No edition available"
    }()

    public lazy var transliteration: NSAttributedString = {
        return self.textEdition?.transliterated() ?? NSAttributedString(string: "No edition available")
    }()

    public lazy var normalisation: NSAttributedString = {
        return self.textEdition?.normalised() ?? NSAttributedString(string: "No edition available")
    }()

    #if os(macOS)
    public lazy var translation: String = {
        return self.textEdition?.scrapeTranslation() ?? self.textEdition?.literalTranslation ?? "No translation available"
    }()
    #elseif os(iOS)
    public lazy var translation: String = {self.textEdition?.literalTranslation ?? "No translation available"}()
    #endif

    public var textEdition: OraccTextEdition?

    public init(_ edition: OraccTextEdition) {
        self.textEdition = edition
    }

    public init(cuneiform: String, transliteration: NSAttributedString, normalisation: NSAttributedString, translation: String) {
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
        guard
            let cuneiform = aDecoder.decodeObject(of: NSString.self, forKey: "cuneiform") as? String,
            let transliteration = aDecoder.decodeObject(of: NSAttributedString.self, forKey: "transliteration"),
            let normalisation = aDecoder.decodeObject(of: NSAttributedString.self, forKey: "normalisation"),
            let translation = aDecoder.decodeObject(of: NSString.self, forKey: "translation") as? String
        else {return nil}

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
