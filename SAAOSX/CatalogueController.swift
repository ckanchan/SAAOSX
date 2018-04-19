//
//  CatalogueController.swift
//  CDKOraccControllers
//
//  Created by Chaitanya Kanchan on 23/02/2018.
//

import OraccJSONtoSwift

/// Defines an interface for objects that can supply Oracc Catalogue data to view controllers and other interested parties.

public protocol CatalogueProvider: AnyObject {
    var name: String { get }
    var count: Int { get }
    var texts: [OraccCatalogEntry] { get }
    
    func text(at row: Int) -> OraccCatalogEntry?
    func search(_ string: String) -> [OraccCatalogEntry]
}

public class CatalogueController: CatalogueProvider {
    public func search(_ string: String) -> [OraccCatalogEntry] {
        return texts.filter{$0.description.lowercased().contains(string.lowercased())}
    }
    
    public var count: Int {
        return texts.count
    }
    
    public func text(at row: Int) -> OraccCatalogEntry? {
        return texts[row]
    }

    public enum CatalogueSource {
        case local, interface, pins
    }
    
    public let catalogue: OraccCatalog
    public let texts: [OraccCatalogEntry]
    public let source: CatalogueSource
    
    
    public lazy var name = {return self.catalogue.project}()
    public init(catalogue: OraccCatalog, sorted: [OraccCatalogEntry], source: CatalogueSource) {
        self.catalogue = catalogue
        self.texts = sorted
        self.source = source
    }
}
