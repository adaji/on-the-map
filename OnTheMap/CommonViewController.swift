//
//  CommonViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/22/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import MBProgressHUD
import FBSDKLoginKit

// MARK: - CommonViewController: UIViewController

// Extract common navigation bar for MapViewController and ListViewController

class CommonViewController: UIViewController {
    
    // MARK: Properties
    
    var shouldReloadData: Bool = false

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload student locations data after user posts/updates location
        if shouldReloadData {
            fetchStudentLocations()
            shouldReloadData = false
            return
        }
        
        // Fetch student locations data only if there is no such data saved locally (in UdacityClient)
        if UdacityClient.sharedInstance().studentLocations == nil {
            fetchStudentLocations()
        } else {
            showStudentLocations(UdacityClient.sharedInstance().studentLocations!)
        }
    }
    
    // MARK: Configure Navigation Bar
    
    // Configure the common navigation bar
    func configureNavigationBar() {
        var logoutButtonItem: UIBarButtonItem
        if (UIApplication.sharedApplication().delegate as! AppDelegate).loggedInWithFB {
            logoutButtonItem = UIBarButtonItem(customView: FBSDKLoginButton())
        } else {
            logoutButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: .Plain, target: self, action: "logout:")
        }
        navigationItem.leftBarButtonItem = logoutButtonItem
        
        let postButtonItem = UIBarButtonItem(image: UIImage(named: "marker"), style: .Plain, target: self, action: "post:")
        let refreshButtonItem = UIBarButtonItem(image: UIImage(named: "refresh"), style: .Plain, target: self, action: "refresh:")
        navigationItem.rightBarButtonItems = [refreshButtonItem, postButtonItem]
    }
    
    // MARK: Show Student Locations
    
    // Show student locations (on map or in table view)
    // To implement in subclasses
    func showStudentLocations(studentLocations: [StudentLocation]) {
        
    }
    
    // MARK: Actions
    
    func logout(sender: UIBarButtonItem) {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Logging out..."
        
        UdacityClient.sharedInstance().deleteSession { (success, errorString) -> Void in
            if success {
                self.completeLogout()
            }
            else {
                self.showError(errorString)
            }
        }
    }
    
    // Check if user has posted location before
    // If so, ask user whether to overwrite
    // If not, present post view controller
    func post(sender: UIBarButtonItem) {
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
    
    func refresh(sender: UIBarButtonItem) {
        fetchStudentLocations()
    }
    
    // MARK: Manipulate Data
    
    // Fetch and show student locations data
    func fetchStudentLocations() {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let parameters = [UdacityClient.ParameterKeys.LimitKey: 100]
        UdacityClient.sharedInstance().getStudentLocations(parameters) { (success, studentLocations, errorString) -> Void in
            
            if success {
                if let studentLocations = studentLocations {
                    // Update student data saved in UdacityClient
                    UdacityClient.sharedInstance().studentLocations = studentLocations

                    dispatch_async(dispatch_get_main_queue(), {
                        hud.hide(true)
                    })
                    
                    self.showStudentLocations(studentLocations)
                }
                else {
                    self.showError("No student data returned.")
                }
            }
            else {
                self.showError(errorString)
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
    func clearSavedData() {
        UdacityClient.sharedInstance().sessionID = nil
        UdacityClient.sharedInstance().userID = nil
        UdacityClient.sharedInstance().studentLocations = nil
        UdacityClient.sharedInstance().myStudentLocation = nil
        
        // Delete password when logout
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue("", forKey: "password")
        userDefaults.synchronize()
    }
    
    // MARK: Helper Functions
    
    // Complete logout
    // - Clear saved data
    // - Show login view
    func completeLogout() {
        clearSavedData()
        
        dispatch_async(dispatch_get_main_queue(), {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    // Show error
    func showError(errorString: String?) {
        let message = !errorString!.isEmpty ? errorString : "An unknown error has occurred."
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

}

// MARK: - CommonViewController: PostViewControllerDelegate

extension CommonViewController: PostViewControllerDelegate {
    
    // If user has just successfully submitted StudentLocation in PostViewController,
    // reload StudentLocations data when the view appears
    func didSubmitStudentLocation() {
        shouldReloadData = true
    }
    
}











