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
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    var shouldReloadData: Bool = false
        
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldReloadData {
            getStudentLocations()
            return
        }
        
        // If there are StudentLocations saved locally, show them on map
        // If there are not, get StudentLocations
        if UdacityClient.sharedInstance().studentLocations == nil {
            getStudentLocations()
        }
        else {
            showStudentLocationsOnMap(UdacityClient.sharedInstance().studentLocations!)
        }
    }
    
    // MARK: Actions
    
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
            }
            else {
                print(errorString)
            }
        }
    }
    
    // Check if user has posted location before
    // If so, ask user whether to overwrite
    // If not, present post view controller
    @IBAction func postButtonTouchUp(sender: UIBarButtonItem) {
        
        checkIfHasPosted { (hasPosted, studentLocation) -> Void in
            
            // If user has posted location before, ask user whether to overwrite
            if hasPosted {
                if let studentLocation = studentLocation {
                    let message = "User \"\(studentLocation.fullName)\" has already posted a Student Location. Would you like to overwrite the location?"
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: { (action) -> Void in
                        self.presentPostViewController()
                    }))
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            else {
                self.presentPostViewController()
            }
        }
    }
    
    // Present post view controller
    func presentPostViewController() {
        let postVC = self.storyboard!.instantiateViewControllerWithIdentifier("PostViewController") as! PostViewController
        postVC.delegate = self
        presentViewController(postVC, animated: true, completion: nil)
    }
    
    @IBAction func refreshButtonTouchUp(sender: UIBarButtonItem) {
        getStudentLocations()
    }
    
    // MARK: Manipulate Data
    
    // Get StudentLocations
    func getStudentLocations() {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)

        let parameters = [UdacityClient.ParameterKeys.LimitKey: 100]
        UdacityClient.sharedInstance().getStudentLocations(parameters) { (success, studentLocations, errorString) -> Void in
            
            if success {
                if let studentLocations = studentLocations {
                    dispatch_async(dispatch_get_main_queue(), {
                        hud.hide(true)
                        self.showStudentLocationsOnMap(studentLocations)
                        print("Get StudentLocations Succeed.")
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
    
    // Check if user has posted location before
    func checkIfHasPosted(completionHandler: (hasPosted: Bool, studentLocation: StudentLocation?) -> Void) {
        
        // Check if user's StudentLocation has been saved locally (as myStudentLocation)
        let myLocation = UdacityClient.sharedInstance().myStudentLocation
        if myLocation != nil {
            completionHandler(hasPosted: true, studentLocation: myLocation)
        }
        else {
            // Query for user's StudentLocation
            
            MBProgressHUD.hideAllHUDsForView(view, animated: true)
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            
            let parameters = [UdacityClient.ParameterKeys.WhereKey: "{\"\(UdacityClient.ParameterKeys.UniqueKey)\":\"\(UdacityClient.sharedInstance().userID!)\"}"]
            UdacityClient.sharedInstance().queryForStudentLocation(parameters) { (success, studentLocation, errorString) -> Void in
                
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        hud.hide(true)
                    })
                    
                    if let studentLocation = studentLocation {
                        completionHandler(hasPosted: true, studentLocation: studentLocation)
                    }
                    else {
                        completionHandler(hasPosted: false, studentLocation: nil)
                    }
                }
                else {
                    completionHandler(hasPosted: false, studentLocation: nil)
                    print(errorString)
                }
            }
        }
    }
    
    // MARK: Show StudentLocations on Map
    
    func showStudentLocationsOnMap(studentLocations: [StudentLocation]) {
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
        
        mapView.addAnnotations(annotations)
    }
    
    // MARK: Helper Functions
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - PostViewControllerDelegate

extension MapViewController: PostViewControllerDelegate {
    
    // If user has just successfully submitted StudentLocation in PostViewController,
    // reload StudentLocations data when the view appears
    func didSubmitStudentLocation() {
        shouldReloadData = true
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
    
    // Open the system browser to the URL specified in the annotationViews subtitle property
    // If the URL is invalid, alert user
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let urlString = view.annotation?.subtitle! {
                let valid = app.openURL(NSURL(string: urlString)!)
                if !valid {
                    showAlert("Invalid Link")
                }
            }
        }
    }
    
}









