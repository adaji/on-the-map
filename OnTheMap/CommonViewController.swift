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
        
        fetchAndShowAllStudentInformation()
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
    
    // Show all student information (in either a map view or a table view)
    //
    // Implement in subclasses
    // Note: This method is used in both the refresh and the viewWillAppear methods.
    // And it is the only part in these two methods that is different for the two view controllers.
    // It makes sense to implement only the different part in subclasses.
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
        checkIfHasPosted { (hasPosted, errorString) -> Void in
            if let errorString = errorString {
                self.showAlert(errorString)
            } else {
                // If user has posted information before, ask user whether to overwrite
                if hasPosted {                    
                    let message = "User \"\(self.model.myStudentInformation!.fullName())\" has already posted a Student Location. Would you like to overwrite the location?"
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: { (action) -> Void in
                        self.presentInfomationPosterViewController()
                    }))
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                } else {
                    self.presentInfomationPosterViewController()
                }
            }
        }
    }
    
    // Present post view controller
    func presentInfomationPosterViewController() {
        let postVC = self.storyboard!.instantiateViewControllerWithIdentifier("InfomationPosterViewController") as! InfomationPosterViewController
        postVC.delegate = self
        postVC.studentInformation = model.myStudentInformation
        presentViewController(postVC, animated: true, completion: nil)
    }
    
    func refresh(sender: UIBarButtonItem) {
        fetchAndShowAllStudentInformation()
    }
    
    // MARK: Manipulate Data
    
    func fetchAndShowAllStudentInformation() {
        fetchAllStudentInformation { (success, errorString) -> Void in
            if success {
                self.showAllStudentInformation()
            } else {
                self.showAlert(errorString)
            }
        }
    }
    
    // Fetch all student information data
    // TODO: Implement "load more" (skip > 0)
    func fetchAllStudentInformation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        ParseClient.sharedInstance().getAllStudentInformation() { (success, allStudentInformation, errorString) -> Void in
            if success {
                // Update student data saved in tab bar controller
                self.model.allStudentInformation = allStudentInformation
                
                dispatch_async(dispatch_get_main_queue(), {
                    hud.hide(true)
                })
                
                completionHandler(success: true, errorString: nil)
            } else {
                completionHandler(success: false, errorString: errorString)
            }
        }
    }
    
    // Check if user has posted information before
    // - If user's information has not been saved in StudentInformation
    // (as myStudentInformation), query for user's information
    func checkIfHasPosted(completionHandler: (hasPosted: Bool, errorString: String?) -> Void) {
        if model.myStudentInformation != nil {
            completionHandler(hasPosted: true, errorString: nil)
        } else {
            MBProgressHUD.hideAllHUDsForView(view, animated: true)
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            
            ParseClient.sharedInstance().queryForStudentInformation({ (success, studentInformation, errorString) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    hud.hide(true)
                })
                
                if success {
                    self.model.myStudentInformation = studentInformation
                    completionHandler(hasPosted: true, errorString: nil)
                } else {
                    completionHandler(hasPosted: false, errorString: errorString)
                }
            })
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

// MARK: - CommonViewController: InfomationPosterViewControllerDelegate

extension CommonViewController: InfomationPosterViewControllerDelegate {
    
    // If user has just successfully submitted StudentInformation in InfomationPosterViewController,
    // reload AllStudentInformation data when the view appears
    func informationPoster(informationPoster: InfomationPosterViewController, didPostInformation information: StudentInformation?) {
        if let submittedInformation = information {
            model.myStudentInformation = submittedInformation
            didSubmitStudentInformation = true
        }
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










