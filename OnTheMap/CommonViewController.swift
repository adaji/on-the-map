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
        
    var model: OnTheMapModel!
    var didSubmitStudentInformation: Bool = false

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = (tabBarController as! OnTheMapTabBarController).model
        
        configureNavigationBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload all student information after user successfully posts/updates information
        if didSubmitStudentInformation {
            fetchAndShowAllStudentInformation()
            didSubmitStudentInformation = false
            return
        }
        
        // Fetch all student information data only if there is
        // no such data stored in tab bar controller
        if model.allStudentInformation == nil {
            fetchAndShowAllStudentInformation()
        } else {
            showAllStudentInformation()
        }
    }
    
    // MARK: Configure Navigation Bar
    
    // Configure the common navigation bar
    func configureNavigationBar() {
        navigationItem.title = "On the Map"
        
        var logoutButtonItem: UIBarButtonItem
        if (UIApplication.sharedApplication().delegate as! AppDelegate).loggedInWithFB {
            let facebookButton = FBSDKLoginButton()
            facebookButton.delegate = self
            facebookButton.frame = CGRect(origin: facebookButton.frame.origin, size: CGSize(width: facebookButton.frame.size.height, height: facebookButton.frame.size.height))
            logoutButtonItem = UIBarButtonItem(customView: facebookButton)
        } else {
            logoutButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: .Plain, target: self, action: "logout:")
        }
        navigationItem.leftBarButtonItem = logoutButtonItem
        
        let postButtonItem = UIBarButtonItem(image: UIImage(named: "marker"), style: .Plain, target: self, action: "post:")
        let refreshButtonItem = UIBarButtonItem(image: UIImage(named: "refresh"), style: .Plain, target: self, action: "refresh:")
        navigationItem.rightBarButtonItems = [refreshButtonItem, postButtonItem]
    }
    
    // MARK: Show All Student Information
    // Implement in subclasses
    
    // Show all student information (on map or in table view)
    // Implement this method in subclasses because this is the only part
    // that is different for map and list view controller when view appears,
    // namely, displaying data on either a map view or table view,
    // The rest is common for the two view controllers
    // and are extracted to this common view controller.
    // Also, I don't (re)load view every time it appears,
    // only when data is fetched (at launch or refresh button is pressed),
    // or when user successfully submit student information.
    func showAllStudentInformation() {
        
    }
    
    // MARK: Actions
    
    func logout(sender: UIBarButtonItem) {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Logging out..."
        
        UdacityClient.sharedInstance().deleteSession { (success, errorString) -> Void in
            if success {
                self.completeLogout()
            } else {
                self.showAlert(errorString)
            }
        }
    }
    
    // Check if user has posted information before
    // If so, ask user whether to overwrite
    // If not, present post view controller
    func post(sender: UIBarButtonItem) {
        checkIfHasPosted { (hasPosted, studentInformation, errorString) -> Void in
            if let errorString = errorString {
                self.showAlert(errorString)
            } else {
                // If user has posted information before, ask user whether to overwrite
                if hasPosted {                    
                    let message = "User \"\(studentInformation!.fullName())\" has already posted a Student Location. Would you like to overwrite the location?"
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: { (action) -> Void in
                        self.presentPostViewController()
                    }))
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                } else {
                    self.presentPostViewController()
                }
            }
        }
    }
    
    // Present post view controller
    func presentPostViewController() {
        let postVC = self.storyboard!.instantiateViewControllerWithIdentifier("PostViewController") as! PostViewController
        postVC.delegate = self
        postVC.studentInformation = model.myStudentInformation
        presentViewController(postVC, animated: true, completion: nil)
    }
    
    func refresh(sender: UIBarButtonItem) {
        fetchAndShowAllStudentInformation()
    }
    
    // MARK: Manipulate Data
    
    // Fetch and show all student information data
    // TODO: Implement "load more" (skip > 0)
    func fetchAndShowAllStudentInformation() {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let parameters = [UdacityClient.ParameterKeys.LimitKey: 100, UdacityClient.ParameterKeys.SkipKey: 0, UdacityClient.ParameterKeys.OrderKey: "-updatedAt"]
        UdacityClient.sharedInstance().getAllStudentInformation(parameters) { (success, allStudentInformation, errorString) -> Void in
            if success {
                if let allStudentInformation = allStudentInformation {
                    // Update student data saved in tab bar controller
                    self.model.allStudentInformation = allStudentInformation
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        hud.hide(true)
                    })
                    
                    self.showAllStudentInformation()
                    
                } else {
                    self.showAlert("No student data returned.")
                }
            } else {
                self.showAlert(errorString)
            }
        }
    }
    
    // Check if user has posted information before
    // - If user's information has not been saved in StudentInformation
    // (as myStudentInformation), query for user's information
    func checkIfHasPosted(completionHandler: (hasPosted: Bool, studentInformation: StudentInformation?, errorString: String?) -> Void) {
        if model.myStudentInformation != nil {
            completionHandler(hasPosted: true, studentInformation: model.myStudentInformation!, errorString: nil)
        } else {
            MBProgressHUD.hideAllHUDsForView(view, animated: true)
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            
            let parameters = [UdacityClient.ParameterKeys.WhereKey: "{\"\(UdacityClient.ParameterKeys.UniqueKey)\":\"\(UdacityClient.sharedInstance().userID!)\"}"]
            UdacityClient.sharedInstance().queryForStudentInformation(parameters) { (success, studentInformation, errorString) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    hud.hide(true)
                })
                
                if success {
                    if let studentInformation = studentInformation {
                        self.model.myStudentInformation = studentInformation
                        
                        completionHandler(hasPosted: true, studentInformation: studentInformation, errorString: nil)
                    } else {
                        completionHandler(hasPosted: false, studentInformation: nil, errorString: "No student data returned.")
                    }
                } else {
                    completionHandler(hasPosted: false, studentInformation: nil, errorString: errorString)
                }
            }
        }
    }
    
    // Clear saved data (student data, password, etc.) on logout
    func clearSavedData() {
        UdacityClient.sharedInstance().sessionID = nil
        UdacityClient.sharedInstance().userID = nil
        model.allStudentInformation = nil
        model.myStudentInformation = nil
        
        // Delete password when logout
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue("", forKey: "password")
        userDefaults.synchronize()
    }
    
    // MARK: Helper Functions
    
    // Open URL with default browser
    // Not using web view because there are many invalid media urls
    // (random string, violate App Transport Security policy, etc.)
    // Safari handles these conditions very well
    func openURL(urlString: String) {
        if let url = NSURL(string: urlString) {
            let success = UIApplication.sharedApplication().openURL(url)
            if !success {
                showAlert("Invalid Link")
            }
        } else {
            showAlert("Invalid Link")
        }
    }
    
    // Open URL with web view
//    func openURL(urlString: String) {
//        if let url = NSURL(string: urlString) {
//            let webVC = storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
//            webVC.urlRequest = NSURLRequest(URL: url)
//            navigationController!.pushViewController(webVC, animated: true)
//        } else {
//            showAlert("Invalid Link")
//        }
//    }
    
    // Complete logout
    // - Clear saved data
    // - Show login view
    func completeLogout() {
        dispatch_async(dispatch_get_main_queue(), {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.dismissViewControllerAnimated(true, completion: nil)
        })

        clearSavedData()
    }
    
    // Show alert
    func showAlert(message: String?) {
        let message = !message!.isEmpty ? message : "An unknown error has occurred."
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
    
    // If user has just successfully submitted StudentInformation in PostViewController,
    // reload AllStudentInformation data when the view appears
    func didSubmitStudentInformation(studentInformation: StudentInformation) {
        model.myStudentInformation = studentInformation
        didSubmitStudentInformation = true
    }
    
}

// MARK: - CommonViewController: FBSDKLoginButtonDelegate

extension CommonViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        UdacityClient.sharedInstance().deleteSession { (success, errorString) -> Void in
            if success {
                self.completeLogout()
            } else {
                self.showAlert(errorString)
            }
        }
    }
    
}










