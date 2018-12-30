//
//  MapViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import MapKit


class MapViewController: NSViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var siteTitle: NSTextField!
    @IBOutlet var siteDescription: NSTextView!
    @IBOutlet weak var siteTableView: NSTableView!
    
    var ancientMapDelegate: AncientMapViewDelegate?
    var ancientMapTableViewDelegate: AncientMapTableViewDelegate?
    
    func setInfo(locationName: String, locationDescription: String) {
        self.siteTitle.stringValue = locationName
        self.siteDescription.string = locationDescription
    }
    
    @discardableResult static func new(forMap map: AncientMap) -> MapViewController?  {
        let storyboard = NSStoryboard(name: "Maps", bundle: Bundle.main)
        guard let mapWindow = storyboard.instantiateController(withIdentifier: "GazetteerViewController") as? NSWindowController else {return nil}
        guard let mapViewController = mapWindow.contentViewController as? MapViewController else {return nil}
        
        mapViewController.ancientMapDelegate = AncientMapViewDelegate(mapView: mapViewController.mapView, mapViewController: mapViewController, ancientMap: map)
        
        mapViewController.mapView.delegate = mapViewController.ancientMapDelegate
        
        mapViewController.ancientMapTableViewDelegate = AncientMapTableViewDelegate(map: map, tableView: mapViewController.siteTableView, mapViewDelegate: mapViewController.ancientMapDelegate)
        mapViewController.siteTableView.dataSource = mapViewController.ancientMapTableViewDelegate
        mapViewController.siteTableView.delegate = mapViewController.ancientMapTableViewDelegate

        
        mapViewController.mapView.mapType = .mutedStandard
        mapViewController.mapView.setCenter(CLLocationCoordinate2D(latitude: 35.45392153, longitude: 43.26224278), animated: false)
        mapWindow.showWindow(nil)
        return mapViewController
    }
}


