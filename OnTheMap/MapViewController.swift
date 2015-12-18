//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import MBProgressHUD
import FBSDKLoginKit

// MARK: - MapViewController: CommonViewController

class MapViewController: CommonViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Life Cycle

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if fetchedResultsController.fetchedObjects!.isEmpty {
            fetchDataAndUpdateView()
        } else {
            // Note: map view doesn't update automatically
            updateView()
        }
    }
    
    // MARK: Update View (Override)
    
    // Show student information data on map
    //
    // Note: implement this method here to avoid re-implementing the refresh method
    // which is extracted in the CommonViewController and uses this method which cannot be extracted
    override func updateView() {
        var annotations = [MKPointAnnotation]()
        
        for studentInformation in self.fetchedResultsController.fetchedObjects as! [StudentInformation] {
            let lat = CLLocationDegrees(studentInformation.latitude)
            let lon = CLLocationDegrees(studentInformation.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = studentInformation.fullName()
            annotation.subtitle = studentInformation.mediaUrl
            annotations.append(annotation)
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }
    
}

// MARK: - MapViewController (FetchedResultsControllerDelegate)

extension MapViewController {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if let annotation = anObject as? MKAnnotation {
            switch type {
            case .Insert:
                mapView.addAnnotation(annotation)
            case .Delete:
                mapView.removeAnnotation(annotation)
            case .Update:
                mapView.removeAnnotation(annotation)
                mapView.addAnnotation(annotation)
            default:
                return
            }
            
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
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










