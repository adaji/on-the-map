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

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if UdacityClient.sharedInstance().studentLocations == nil {
            getStudentLocations()
        }
    }
    
    @IBAction func LogoutButtonTouchUp(sender: UIBarButtonItem) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud!.labelText = "Logging out..."

        UdacityClient.sharedInstance().deleteUdacitySession { (success, errorString) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    hud.hide(true)
                })

                // Delete password when logout
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setValue("", forKey: "password")
                userDefaults.synchronize()

                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                print(errorString)
            }
        }
    }
    
    @IBAction func postButtonTouchUp(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func refreshButtonTouchUp(sender: UIBarButtonItem) {
        getStudentLocations()
    }
    
    // MARK: Helper Functions
    
    // Get StudentLocations
    func getStudentLocations() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud!.labelText = "Loading..."

        let parameters = [UdacityClient.ParameterKeys.LimitKey: 100]
        UdacityClient.sharedInstance().getStudentLocations(parameters) { (success, studentLocations, errorString) -> Void in
            
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    hud.hide(true)
                    self.mapView.addAnnotations(self.annotationsFromStudentLocations(studentLocations!))
                })
                
                print("Student locations: \(studentLocations)")
            }
            else {
                print(errorString)
            }
        }
    }
    
    // Get an array of annotations from an array of StudentLocation
    func annotationsFromStudentLocations(studentLocations: [StudentLocation]) -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        
        for location in studentLocations {
            let lat = CLLocationDegrees(location.latitude)
            let lon = CLLocationDegrees(location.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = location.fullName
            annotation.subtitle = location.mediaURL
            
            annotations.append(annotation)
        }
        
        return annotations
    }
    
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let urlString = view.annotation?.subtitle! {
                app.openURL(NSURL(string: urlString)!)
            }
        }
    }
}









