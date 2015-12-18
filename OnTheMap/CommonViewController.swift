//
//  CommonViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/22/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD
import FBSDKLoginKit

// MARK: - CommonViewController: UIViewController, NSFetchedResultsControllerDelegate

// Extract common navigation bar for MapViewController and ListViewController

class CommonViewController: UIViewController, NSFetchedResultsControllerDelegate {
            
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unresolved error: \(error)")
            abort()
        }
        
        fetchedResultsController.delegate = self
    }
    
    // MARK: Configure Navigation Bar
    
    // Configure the common navigation bar
    func configureNavigationBar() {
//        navigationItem.title = "On the Map"
        
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
        
        let searchButton = UIBarButtonItem(image: UIImage(named: "search"), style: .Plain, target: self, action: "search:")
        let refreshButtonItem = UIBarButtonItem(image: UIImage(named: "refresh"), style: .Plain, target: self, action: "refresh:")
        let postButtonItem = UIBarButtonItem(image: UIImage(named: "marker"), style: .Plain, target: self, action: "post:")
        navigationItem.rightBarButtonItems = [searchButton, refreshButtonItem, postButtonItem]
    }
    
    // MARK: Actions
    
    // Check if user has posted information before
    // If so, ask user whether to overwrite
    // If not, present post view controller
    func post(sender: UIBarButtonItem) {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        ParseClient.sharedInstance().queryForStudentInformation({ (success, studentInformationDictionary, errorString) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                hud.hide(true)
            })
            
            if success {
                let message = "User \"\(studentInformationDictionary![StudentInformation.Keys.FirstName] as! String) \(studentInformationDictionary![StudentInformation.Keys.LastName] as! String)\" has already posted a Student Location. Would you like to overwrite the location?"
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: { (action) -> Void in
                    let postVC = self.storyboard!.instantiateViewControllerWithIdentifier("InfomationPosterViewController") as! InfomationPosterViewController
                    postVC.delegate = self
                    postVC.studentInformationDictionary = studentInformationDictionary
                    self.presentViewController(postVC, animated: true, completion: nil)
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alertController, animated: true, completion: nil)
                }

            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let postVC = self.storyboard!.instantiateViewControllerWithIdentifier("InfomationPosterViewController") as! InfomationPosterViewController
                    postVC.delegate = self
                    self.presentViewController(postVC, animated: true, completion: nil)
                }
            }
        })
    }
    
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
    
    func refresh(sender: UIBarButtonItem) {
        deleteAllStudentInformation()
        fetchDataAndUpdateView()
    }
    
    func search(sender: UIBarButtonItem) {
        let searchVC = storyboard!.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        presentViewController(searchVC, animated: true, completion: nil)
    }
    
    // MARK: Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "StudentInformation")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: StudentInformation.Keys.UpdatedAt, ascending: false)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    // MARK: Manipulate Data
    
    func deleteAllStudentInformation() {
        for studentInformation in fetchedResultsController.fetchedObjects as! [StudentInformation] {
            sharedContext.deleteObject(studentInformation)
        }
        
        // Use NSBatchDeleteRequest
        // Note that the changes are not reflected in the context, but rather in the persistent storage
//        let fetchRequest = NSFetchRequest(entityName: "StudentInformation")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        
//        do {
//            try sharedContext.executeRequest(deleteRequest)
//        } catch let error as NSError {
//            print("Unable to delete: \(error)")
//        }
    }
    
    // Fetch and show student information data
    // TODO: Implement "load more" (skip > 0)
    func fetchDataAndUpdateView() {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        MBProgressHUD.showHUDAddedTo(view, animated: true)

        ParseClient.sharedInstance().getStudentInformationData() { (success, studentInformationDictionaries, errorString) -> Void in
            if success {
                
                // Create an array of StudentInformation instances from the dictionaries asynchronously
                self.sharedContext.performBlock {
                    let _ = studentInformationDictionaries!.map() {
                        StudentInformation(dictionary: $0, context: self.sharedContext)
                    }
                    
                    // Update view on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        self.updateView()
                    }
                }

            } else {
                self.showAlert(errorString)
            }
        }
    }
    
    // Check if user has posted information before
    func checkIfHasPosted(completionHandler: (hasPosted: Bool, errorString: String?) -> Void) {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        ParseClient.sharedInstance().queryForStudentInformation({ (success, studentInformationDictionary, errorString) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                hud.hide(true)
            })
            
            if success {
                
                completionHandler(hasPosted: true, errorString: nil)
            } else {
                completionHandler(hasPosted: false, errorString: errorString)
            }
        })
    }
    
    // Delete all saved data (student data, password, etc.) on logout
    func deleteAllData() {
        UdacityClient.sharedInstance().sessionID = nil
        UdacityClient.sharedInstance().userID = nil
        deleteAllStudentInformation()
        // Delete password when logout
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue("", forKey: "password")
        userDefaults.synchronize()
    }
    
    // MARK: Show All Student Information
    
    // Implement in sub-classes
    func updateView() {
        
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
    
    // Complete logout
    // - Clear saved data
    // - Show login view
    func completeLogout() {
        dispatch_async(dispatch_get_main_queue()) {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }

        deleteAllData()
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
    
    // If user has just successfully submitted student information in InfomationPosterViewController,
    // create a new StudentInformation instance
    func informationPoster(informationPoster: InfomationPosterViewController, didPostStudentInformationDictionary dictionary: [String: AnyObject]?) {
        if let dictionary = dictionary {
            let _ = StudentInformation(dictionary: dictionary, context: sharedContext)
            saveContext()
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










