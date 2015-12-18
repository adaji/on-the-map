//
//  InfomationPosterViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/20/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD

// MARK: - InfomationPosterViewControllerDelegate

protocol InfomationPosterViewControllerDelegate {
    func informationPoster(informationPoster: InfomationPosterViewController, didPostStudentInformationDictionary dictionary: [String: AnyObject]?)
}

// MARK: - InfomationPosterViewController: UIViewController

class InfomationPosterViewController: UIViewController {
    
    // Properties
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var findButton: BorderedButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topCoverView: UIView!
    @IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var submitButton: BorderedButton!
    @IBOutlet weak var submitButtonContainer: UIView!
    
    var activityIndicator: UIActivityIndicatorView? = nil
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    var delegate: InfomationPosterViewControllerDelegate?
    
    var studentInformationDictionary: [String: AnyObject]? = nil
    var update: Bool = false
    
    let locationPlaceholderText = "Enter Your Location Here"
    let urlPlaceholderText = "Enter a Link to Share Here"
    let lightGrayColor = UIColor(red: 217/255.0, green: 217/255.0, blue: 213/255.0, alpha: 1)
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        initData()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator!.center = view.center
    }
    
    func initData() {
        if studentInformationDictionary == nil {
            update = false
            
            // Initialize studentInformationDictionary
            studentInformationDictionary = [StudentInformation.Keys.UniqueKey: UdacityClient.sharedInstance().userID!]
            UdacityClient.sharedInstance().getUserDictionary(UdacityClient.sharedInstance().userID!, completionHandler: { (success, userDictionary, errorString) -> Void in
                if success {
                    self.studentInformationDictionary![StudentInformation.Keys.FirstName] = userDictionary![UdacityClient.JSONResponseKeys.FirstName] as! String
                    self.studentInformationDictionary![StudentInformation.Keys.LastName] = userDictionary![UdacityClient.JSONResponseKeys.LastName] as! String
                } else {
                    self.showAlert("Unable to fetch user data")
                }
            })
        } else {
            update = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUIForEnteringLocation()
        
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardDismissRecognizer()
    }
    
    // MARK: Actions
    
    // Function: findButtonTouchUp
    //
    // Check if user has entered a valid location
    // If so,
    // - save latitude, longitude and map string
    // - configure UI for entering URL and submitting StudentInformation
    // If not, alert user
    @IBAction func findButtonTouchUp(sender: UIButton) {
        if locationTextView.text == locationPlaceholderText {
            showAlert("Please enter a location.")
        } else {
            findLocation({ (success, placemark, errorString) -> Void in
                if success {
                    if let placemark = placemark {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.configureUIForSubmit(placemark)
                        })
                        
                        let coordinates = placemark.location!.coordinate
                        self.studentInformationDictionary![StudentInformation.Keys.Latitude] = coordinates.latitude
                        self.studentInformationDictionary![StudentInformation.Keys.Longitude] = coordinates.longitude
                        self.studentInformationDictionary![StudentInformation.Keys.MapString] = self.locationTextView.text
                    }
                } else {
                    self.showAlert("Could not find the location.")
                    print("Could not find \"\(self.locationTextView.text)\" on map. Error: \(errorString)")
                }
            })
        }
    }
    
    // Function: submitButtonTouchUp
    //
    // Check if user has entered some text
    // If so, 
    // - save mediaUrl
    // - submit StudentInformation
    // If not, alert user
    // TODO: Check if the text is a valid URL string
    @IBAction func submitButtonTouchUp(sender: UIButton) {
        if urlTextView.text == urlPlaceholderText {
            showAlert("Please enter a link.")
        } else {
            studentInformationDictionary![StudentInformation.Keys.MediaUrl] = urlTextView.text
            
            submitStudentInformation()
        }
    }
    
    @IBAction func cancelButtonTouchUp(sender: UIButton) {
        delegate?.informationPoster(self, didPostStudentInformationDictionary: nil)
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Configure UI
    
    func configureUI() {
        let attributedText = NSMutableAttributedString()
        attributedText.appendAttributedString(NSAttributedString(string: "Where are you\n", attributes: [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Thin", size: 28)!]))
        attributedText.appendAttributedString(NSAttributedString(string: "studying\n", attributes: [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Regular", size: 28)!]))
        attributedText.appendAttributedString(NSAttributedString(string: "today?", attributes: [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Thin", size: 28)!]))
        attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: NSRangeFromString(attributedText.string))
        textLabel.attributedText = attributedText
        
        for button in [findButton, submitButton] {
            button.setTitleColor(UIColor.orangeColor(), forState: .Normal)
            button.setTitleColor(UIColor.orangeColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
            button.backgroundColor = UIColor.whiteColor()
            button.backingColor = UIColor.whiteColor()
            button.highlightedBackingColor = UIColor.whiteColor()
        }
        
        mapView.userInteractionEnabled = false
    }
    
    // Configure UI for entering location
    func configureUIForEnteringLocation() {
        cancelButton.tintColor = UIColor.orangeColor()
        
        mapView.hidden = true
        topCoverView.hidden = true
        urlTextView.hidden = true
        submitButton.hidden = true
        submitButtonContainer.backgroundColor = lightGrayColor
    }
    
    // Configure UI for entering link and submitting StudentInformation
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
        submitButtonContainer.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)

        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    // MARK: Find Location

    // Find the location that user has entered
    func findLocation(completionHandler: (success: Bool, placemark: MKPlacemark?, errorString: String?) -> Void) {
        // Indicate activity during geocoding
        startIndicatingActivity()
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTextView.text, completionHandler: { (placemarks, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.stopIndicatingActivity()
            })
            
            if let error = error {
                completionHandler(success: false, placemark: nil, errorString: error.localizedDescription)
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
    
    // MARK: Submit Student Information
    
    func submitStudentInformation() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        ParseClient.sharedInstance().submitStudentInformation(update, dictionary: studentInformationDictionary!) { (success, errorString) -> Void in
            if success {
                self.delegate?.informationPoster(self, didPostStudentInformationDictionary: self.studentInformationDictionary)
                
                dispatch_async(dispatch_get_main_queue()) {
                    hud.hide(true)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                print("Submit Location Succeed.")
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    hud.hide(true)
                    self.showAlert(errorString)
                }
                
                print(errorString)
            }
        }
    }
    
    // MARK: Indicate Activity
    
    func startIndicatingActivity() {
        // TODO: Add animation to alpha change
        view.alpha = 0.5
        
        if activityIndicator != nil {
            activityIndicator!.startAnimating()
            view.addSubview(activityIndicator!)
        }
    }
    
    func stopIndicatingActivity() {
        if activityIndicator != nil {
            activityIndicator!.stopAnimating()
            activityIndicator!.removeFromSuperview()
        }
        
        view.alpha = 1.0
    }
    
    // MARK: Show Alert
    
    func showAlert(message: String?) {
        let message = !message!.isEmpty ? message : "An unknown error has occurred."
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    // MARK: Show/Hide Keyboard
    
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}

// MARK: - InfomationPosterViewController: UITextViewDelegate

extension InfomationPosterViewController: UITextViewDelegate {
    
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
            } else if textView == urlTextView {
                textView.text = urlPlaceholderText
            }
            textView.textColor = lightGrayColor
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



















