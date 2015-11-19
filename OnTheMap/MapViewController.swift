//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parameters = [
            UdacityClient.ParameterKeys.LimitKey: 200
        ]
        UdacityClient.sharedInstance().getStudentLocations(parameters) { (success, studentLocations, errorString) -> Void in
            if success {
                print("Student locations: \(studentLocations)")
            } else {
                print(errorString)
            }
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        UdacityClient.sharedInstance().get
    }
    
    @IBAction func LogoutButtonTouch(sender: UIBarButtonItem) {
        UdacityClient.sharedInstance().deleteUdacitySession { (success, errorString) -> Void in
            if success {
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
    
}











