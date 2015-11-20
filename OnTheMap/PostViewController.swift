//
//  PostViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/20/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import MapKit

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
    
    var studentLocation: StudentLocation? = nil
    
    // Actions
    
    @IBAction func findButtonTouchUp(sender: UIButton) {
        
        textLabel.hidden = true
        locationTextView.hidden = true
        findButton.hidden = true
        
        cancelButton.tintColor = UIColor.whiteColor()
        mapView.hidden = false
        topCoverView.hidden = false
        urlTextView.hidden = false
        submitButton.hidden = false
    }
    
    @IBAction func submitButtonTouchUp(sender: UIButton) {
        UdacityClient.sharedInstance().postStudentLocation(StudentLocation.dictionaryFromStudentLocation(studentLocation!)) { (success, errorString) -> Void in
            
            if success {
                print("Post Location Success.")
            }
            else {
                print(errorString)
            }
        }
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if studentLocation == nil {
            studentLocation = StudentLocation(dictionary: [UdacityClient.StudentLocationKeys.UniqueKey: UdacityClient.sharedInstance().userID!])
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cancelButton.tintColor = UIColor.orangeColor()
        mapView.hidden = true
        topCoverView.hidden = true
        urlTextView.hidden = true
        submitButton.hidden = true
    }
    
}


















