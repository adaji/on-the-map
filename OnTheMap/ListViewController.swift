//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import MBProgressHUD

class ListViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var locationsTableView: UITableView!
    
    var shouldReloadData: Bool = false
    var studentLocations = [StudentLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            studentLocations = UdacityClient.sharedInstance().studentLocations!
            locationsTableView.reloadData()
        }
    }
    
    // MARK: Actions
    
    @IBAction func logoutButtonTouchUp(sender: UIBarButtonItem) {
        
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
                    self.studentLocations = studentLocations
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        hud.hide(true)
                        
                        self.locationsTableView.reloadData()
                    })
                }
                else {
                    self.showError(errorString)
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
    
    // MARK: Helper Functions
    
    // Complete logout
    // - Delete password (saved in userDefaults)
    // - Show login view
    func completeLogout() {
        // Delete password on logout
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue("", forKey: "password")
        userDefaults.synchronize()
        
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

extension ListViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let reuseId = "StudentLocationCell"
        var cell: UITableViewCell
        if let reusableCell = tableView.dequeueReusableCellWithIdentifier(reuseId) {
            cell = reusableCell
        }
        else {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: reuseId)
        }
        
        if let studentLocation: StudentLocation = studentLocations[indexPath.row] {
            cell.textLabel!.text =  studentLocation.fullName
            cell.detailTextLabel!.text = studentLocation.mediaURL
            cell.detailTextLabel!.textColor = UIColor.lightGrayColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let studentLocation: StudentLocation = studentLocations[indexPath.row] {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: studentLocation.mediaURL)!)
        }
    }
    
}

// MARK: - ListViewController: PostViewControllerDelegate

extension ListViewController: PostViewControllerDelegate {
    
    // If user has just successfully submitted StudentLocation in PostViewController,
    // reload StudentLocations data when the view appears
    func didSubmitStudentLocation() {
        shouldReloadData = true
    }
    
}










