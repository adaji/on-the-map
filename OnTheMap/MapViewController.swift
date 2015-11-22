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

class MapViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    var shouldReloadData: Bool = false
        
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLogoutButton()
    }
    
    func configureLogoutButton() {
        var logoutButtonItem: UIBarButtonItem
        if (UIApplication.sharedApplication().delegate as! AppDelegate).loggedInWithFB {
            logoutButtonItem = UIBarButtonItem(customView: FBSDKLoginButton())
        } else {
            logoutButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: .Plain, target: self, action: "logout:")
        }
        navigationItem.leftBarButtonItem = logoutButtonItem
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldReloadData {
            getStudentLocations()
            shouldReloadData = false
            
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
    
    @IBAction func logout(sender: UIBarButtonItem) {
        
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Logging out..."

        UdacityClient.sharedInstance().deleteSession { (success, errorString) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    hud.hide(true)
                })
                
                self.clearDataOnLogout()

                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    hud.hide(true)
                    self.showAlert("An error has occurred during logging out.")
                })

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
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
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
                        self.showAlert(errorString)
                    })
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    hud.hide(true)
                    self.showAlert(errorString)
                })
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
    
    // Clear saved data (student data, password, etc.) on logout
    func clearDataOnLogout() {
        UdacityClient.sharedInstance().sessionID = nil
        UdacityClient.sharedInstance().userID = nil
        UdacityClient.sharedInstance().studentLocations = nil
        UdacityClient.sharedInstance().myStudentLocation = nil
        
        // Delete password when logout
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue("", forKey: "password")
        userDefaults.synchronize()
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
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    // MARK: Helper Functions
    
    func showAlert(message: String?) {
        let message = !message!.isEmpty ? message : "An unknown error has occurred."
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
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

// MARK: - MapViewController: PostViewControllerDelegate

extension MapViewController: PostViewControllerDelegate {
    
    // If user has just successfully submitted StudentLocation in PostViewController,
    // reload StudentLocations data when the view appears
    func didSubmitStudentLocation() {
        shouldReloadData = true
    }
    
}









