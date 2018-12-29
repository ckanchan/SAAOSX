//
//  AncientMapViewDelegate.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 28/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import MapKit

class AncientMapViewDelegate: NSObject, MKMapViewDelegate {
    
    let ancientMap: AncientMap
    weak var mapView: MKMapView?

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
            view.rightCalloutAccessoryView = NSButton(title: "More", target: nil, action: nil)
            
            annotationView = view
        }
        return annotationView
    }
    
    func updateAnnotations(with places: [String: AncientLocation]) {
        let annotations = Array(places.values)
        guard let mapView = self.mapView else {return}
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    init(mapView: MKMapView, ancientMap: AncientMap) {
        self.mapView = mapView
        self.ancientMap = ancientMap
        super.init()
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(self.ancientMap.locations)
//        self.ancientMap.getPleiadesPlaces(then: updateAnnotations)
    }

}
