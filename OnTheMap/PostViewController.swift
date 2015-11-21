//
//  PostViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/20/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD

// MARK: Protocols

protocol PostViewControllerDelegate {
    
    func didSubmitStudentLocation()
    
}

class PostViewController: UIViewController {
    
    // Properties
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var findButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topCoverView: UIView!
    @IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    var delegate: PostViewControllerDelegate?
    
    var hasPosted: Bool = false // Whether user has posted location before
    var myStudentLocation: StudentLocation? = nil
    
    let locationPlaceholderText = "Enter Your Location Here"
    let urlPlaceholderText = "Enter a Link to Share Here"
    let placeholderTextColor = UIColor(red: 217/255.0, green: 217/255.0, blue: 213/255.0, alpha: 1)
    
    // Actions
    
    // Function: findButtonTouchUp
    //
    // Check if user has entered a valid location
    // If so,
    // - save latitude and longitude of the location in myStudentLocation
    // - configure UI for entering URL and submitting StudentLocation
    // If not, alert user
    @IBAction func findButtonTouchUp(sender: UIButton) {
        
        if locationTextView.text == locationPlaceholderText {
            showAlert("Please enter a location.")
        }
        else {
            findLocation({ (success, placemark, errorString) -> Void in
                
                if success {
                    if let placemark = placemark {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.configureUIForSubmit(placemark)
                        })
                        
                        let coordinates = placemark.location!.coordinate
                        self.myStudentLocation!.latitude = coordinates.latitude
                        self.myStudentLocation!.longitude = coordinates.longitude
                    }
                }
                else {
                    let alertController = UIAlertController(title: nil, message: "Could not find the location.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                    print("Could not find \"\(self.locationTextView.text)\" on map. Error: \(errorString)")
                }
            })
        }
    }
    
    // Function: submitButtonTouchUp
    //
    // Check if user has entered some text
    // If so, 
    // - save the text in myStudentLocation (as mediaURL)
    // - submit myStudentLocation
    // If not, alert user
    // TODO: Check if the text is a valid URL string
    @IBAction func submitButtonTouchUp(sender: UIButton) {
        
        if urlTextView.text == urlPlaceholderText {
            showAlert("Please enter a link.")
        }
        else {
            myStudentLocation!.mediaURL = urlTextView.text
            
            submitStudentLocation()
        }
    }
    
    @IBAction func cancelButtonTouchUp(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
    }
    
    // Initialize data (myStudentLocation, hasPosted)
    // If user's student location has been saved locally, set myStudentLocation to this location
    // If not, create a new StudentLocation with user's Udacity account (user) id
    func initData() {
        if UdacityClient.sharedInstance().myStudentLocation == nil {
            hasPosted = false
            myStudentLocation = StudentLocation(dictionary: [UdacityClient.StudentLocationKeys.UniqueKey: UdacityClient.sharedInstance().userID!])
        }
        else {
            hasPosted = true
            myStudentLocation = UdacityClient.sharedInstance().myStudentLocation
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUIForEnteringLocation()
    }
    
    // MARK: Configure UI
    
    // Configure UI for entering location
    func configureUIForEnteringLocation() {
        
        cancelButton.tintColor = UIColor.orangeColor()
        
        mapView.hidden = true
        topCoverView.hidden = true
        urlTextView.hidden = true
        submitButton.hidden = true
    }
    
    // Configure UI for entering link and submitting StudentLocation
    // Show user entered location on map
    func configureUIForSubmit(annotation: MKAnnotation) {
        
        cancelButton.tintColor = UIColor.whiteColor()

        textLabel.hidden = true
        locationTextView.hidden = true
        findButton.hidden = true
        
        mapView.hidden = false
        topCoverView.hidden = false
        urlTextView.hidden = false
        submitButton.hidden = false

        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    // MARK: Find Location

    // Find the location that user has entered
    func findLocation(completionHandler: (success: Bool, placemark: MKPlacemark?, errorString: String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTextView.text, completionHandler: { (placemarks, error) -> Void in
            
            if let error = error {
                completionHandler(success: false, placemark: nil, errorString: error.description)
                return
            }

            if let placemarks = placemarks {
                let placemark = MKPlacemark(placemark: placemarks[0])
                completionHandler(success: true, placemark: placemark, errorString: nil)
                return
            }
            
            completionHandler(success: false, placemark: nil, errorString: "Could not find the location.")
        })
    }
    
    // MARK: Submit StudentLocation
    
    // Submit myStudentLocation
    // If user has posted location before, update the location
    // If not, post it (as a new StudentLocation object)
    //
    // If submission succeeds, update myStudentLocation stored in UdacityClient
    func submitStudentLocation() {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let locationDictionary = StudentLocation.dictionaryFromStudentLocation(myStudentLocation!)
        
        UdacityClient.sharedInstance().submitStudentLocation(hasPosted, locationDictionary: locationDictionary) { (success, errorString) -> Void in
            
            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    hud.hide(true)
                })
                
                self.delegate!.didSubmitStudentLocation()
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
                UdacityClient.sharedInstance().myStudentLocation = self.myStudentLocation
                print("Update Location Succeed.")
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    hud.hide(true)
                    self.showAlert(errorString)
                })
                
                print(errorString)
            }
        }
    }
    
    // MARK: Helper Functions
    
    func showAlert(message: String?) {
        let message = !message!.isEmpty ? message : "An unknown error has occurred."
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

// MARK: - PostViewController: UITextViewDelegate

extension PostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView.text == locationPlaceholderText || textView.text == urlPlaceholderText {
            textView.text = ""
            textView.textColor = UIColor.whiteColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if textView.text!.isEmpty {
            if textView == locationTextView {
                textView.text = locationPlaceholderText
            }
            else if textView == urlTextView {
                textView.text = urlPlaceholderText
            }
            textView.textColor = placeholderTextColor
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
}



















