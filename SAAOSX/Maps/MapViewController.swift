//
//  MapViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 21/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import MapKit
import CDKSwiftOracc

class MapViewController: NSViewController, MKMapViewDelegate {
    
    var entry: OraccCatalogEntry? {
        didSet {
            if let entry = entry {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let pleiadesID = entry.pleiadesID,
                        let record = MapViewController.lookupInPleiades(id: pleiadesID),
                        let location = AncientLocation(for: record) else {return}
                    DispatchQueue.main.async { [weak self] in
                        self?.site = location
                    }
                }
            }
        }
    }

    var site: AncientLocation? {
        didSet {
            if let site = site {
                mapView.addAnnotation(site)
                mapView.centerCoordinate = site.coordinate
                siteTitle.stringValue = site.title ?? ""
                siteDescription.string = site.pleiadesRecord.description
            }
        }
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var siteTitle: NSTextField!
    @IBOutlet var siteDescription: NSTextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @discardableResult static func new(forText text: OraccCatalogEntry) -> MapViewController?  {
        let storyboard = NSStoryboard(name: "Maps", bundle: Bundle.main)
        guard let mapWindow = storyboard.instantiateController(withIdentifier: "MapWindowController") as? NSWindowController else {return nil}
        guard let mapView = mapWindow.contentViewController as? MapViewController else {return nil}
        mapView.mapView.delegate = mapView
        mapView.entry = text
        mapWindow.showWindow(nil)
        return mapView
    }
    
    static func lookupInPleiades(id: Int) -> PleaidesRecord? {
        guard let url = URL(string: "https://pleiades.stoa.org/places/\(id)/json") else {return nil}
        guard let data = try? Data.init(contentsOf: url) else {return nil}
        let decoder = JSONDecoder()
        guard let geoJSON = try? decoder.decode(PleaidesRecord.self, from: data) else {return nil}
        return geoJSON
    }
}
