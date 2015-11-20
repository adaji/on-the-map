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
        else {
            self.mapView.addAnnotations(self.annotationsFromStudentLocations(UdacityClient.sharedInstance().studentLocations!))
        }
    }
    
    @IBAction func LogoutButtonTouchUp(sender: UIBarButtonItem) {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Logging out..."

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
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Checking..."
        
        let parameters = [UdacityClient.ParameterKeys.WhereKey: "{\"\(UdacityClient.ParameterKeys.UniqueKey)\":\"\(UdacityClient.sharedInstance().userID!)\"}"]
        UdacityClient.sharedInstance().getStudentLocation(parameters) { (success, studentLocation, errorString) -> Void in

            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    hud.hide(true)
                })
                
                // Ask user whether to overwrite previous post data
                if let studentLocation = studentLocation {
                    let message = "User \"\(studentLocation.fullName)\" has already posted a Student Location. Would you like to overwrite the location?"
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: { (action) -> Void in
                        self.post()
                    }))
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    print("Student location: \(studentLocation)")
                }
            }
            else {
                print(errorString)
            }
        }
    }
    
    func post() {
        
    }
    
    @IBAction func refreshButtonTouchUp(sender: UIBarButtonItem) {
        getStudentLocations()
    }
    
    // MARK: Helper Functions
    
    // Get StudentLocations
    func getStudentLocations() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Loading..."

        let parameters = [UdacityClient.ParameterKeys.LimitKey: 100]
        UdacityClient.sharedInstance().getStudentLocations(parameters) { (success, studentLocations, errorString) -> Void in
            
            if success {
                if let studentLocations = studentLocations {
                    dispatch_async(dispatch_get_main_queue(), {
                        hud.hide(true)
                        self.mapView.addAnnotations(self.annotationsFromStudentLocations(studentLocations))
                    })
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), {
                        hud.hide(true)
                    })
                }
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









