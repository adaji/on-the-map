//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import MBProgressHUD

class ListViewController: CommonViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var locationsTableView: UITableView!
    
    var studentLocations = [StudentLocation]()
    
    // MARK: Show StudentLocations (Override)
    
    override func showStudentLocations(studentLocations: [StudentLocation]) {
        super.showStudentLocations(studentLocations)
        
        self.studentLocations = studentLocations
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.locationsTableView.reloadData()
        }
    }
    
}

// MARK: - ListViewController: UITableViewDataSource, UITableViewDelegate

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











