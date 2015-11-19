//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    // MARK: Properties
    
    var studentLocations = [StudentLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if UdacityClient.sharedInstance().studentLocations != nil {
            studentLocations = UdacityClient.sharedInstance().studentLocations!
        }
        else {
            getStudentLocations()
        }
    }
    
    // MARK: Actions
    
    @IBAction func logoutButtonTouch(sender: UIBarButtonItem) {
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
    
    @IBAction func postButtonTouch(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func refreshButtonTouch(sender: UIBarButtonItem) {
        getStudentLocations()
    }
    
    // MARK: Helper Functions
    
    // Get StudentLocations
    func getStudentLocations() {
        let parameters = [UdacityClient.ParameterKeys.LimitKey: 100]
        UdacityClient.sharedInstance().getStudentLocations(parameters) { (success, studentLocations, errorString) -> Void in
            
            if success {
                self.studentLocations = studentLocations!
                print("Student locations: \(studentLocations)")
            }
            else {
                print(errorString)
            }
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
            cell.imageView!.image = UIImage(named: "marker")
            cell.imageView!.tintColor = UIColor.orangeColor()
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










