//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD
import FBSDKLoginKit

// MARK: - MapViewController: CommonViewController

class MapViewController: CommonViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Show All Student Information (Override)
    
    override func showAllStudentInformation(allStudentInformation: [StudentInformation]) {
        super.showAllStudentInformation(allStudentInformation)
        
        showAllStudentInformationOnMap(allStudentInformation)
    }
    
    // Show all student information on map
    func showAllStudentInformationOnMap(allStudentInformation: [StudentInformation]) {
        var annotations = [MKPointAnnotation]()
        
        for studentInformation in allStudentInformation {
            let lat = CLLocationDegrees(studentInformation.latitude)
            let lon = CLLocationDegrees(studentInformation.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = studentInformation.fullName()
            annotation.subtitle = studentInformation.mediaURL
            
            annotations.append(annotation)
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
        }
    }
    
}

// MARK: - MapViewController: MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // Open the system browser to the URL specified in the annotationViews subtitle property
    // If the URL is invalid, alert user
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let urlString = view.annotation?.subtitle! {
                openURL(urlString)
            } else {
                showAlert("No valid URL.")
            }
        }
    }
        
}










