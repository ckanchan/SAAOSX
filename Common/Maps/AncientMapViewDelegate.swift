//
//  AncientMapViewDelegate.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 28/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import MapKit

class AncientMapViewDelegate: NSObject, MKMapViewDelegate {
    
    let ancientMap: AncientMap
    weak var mapView: MKMapView?
    weak var mapViewDelegateDelegate: MapViewDelegateDelegate?

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "AncientLocation"
        guard let annotation = annotation as? AncientLocation else {return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if let annotationView = annotationView {
            annotationView.annotation = annotation
        } else {
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            
            let textView = NSTextView()
            textView.isEditable = false
            textView.string = annotation.title ?? ""
            textView.sizeToFit()
            view.leftCalloutAccessoryView = textView
            
            annotationView = view
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? AncientLocation else {return}
        let description: String
        if let record = annotation.pleiadesRecord,
            let siteDescription = annotation.subtitle {
            description = siteDescription + "\n" + record.rights
        } else {
            description = annotation.subtitle ?? "No description available"
        }
        
        mapViewDelegateDelegate?.setInfo(locationName: annotation.title ?? "", locationDescription: description)
    }
    
    func selectAnnotation(qpnID: String) {
        guard let location = ancientMap.getLocationForQpnID(qpnID) else {return}
        guard let annotation = mapView?.annotations.first(where: {$0.coordinate == location.coordinate}) else {return}
        mapView?.selectAnnotation(annotation, animated: true)
    }
    
    func updateAnnotations(with places: [String: AncientLocation]) {
        let annotations = Array(places.values)
        guard let mapView = self.mapView else {return}
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    init(mapView: MKMapView, mapViewDelegateDelegate: MapViewDelegateDelegate, ancientMap: AncientMap) {
        self.mapView = mapView
        self.mapViewDelegateDelegate = mapViewDelegateDelegate
        self.ancientMap = ancientMap
        super.init()
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(self.ancientMap.locations)
    }
}

protocol MapViewDelegateDelegate {
    func setInfo(locationName: String, locationDescription: String)
}
