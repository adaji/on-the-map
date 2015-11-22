//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import MBProgressHUD

// MARK: - ListViewController: CommonViewController

class ListViewController: CommonViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var locationsTableView: UITableView!
    
    var allStudentInformation = [StudentInformation]()
    
    // MARK: Show AllStudentInformation (Override)
    
    override func showAllStudentInformation(allStudentInformation: [StudentInformation]) {
        super.showAllStudentInformation(allStudentInformation)
        
        self.allStudentInformation = allStudentInformation
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.locationsTableView.reloadData()
        }
    }
    
}

// MARK: - ListViewController: UITableViewDataSource, UITableViewDelegate

extension ListViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStudentInformation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId = "StudentInformationCell"
        
        var cell: UITableViewCell
        if let reusableCell = tableView.dequeueReusableCellWithIdentifier(reuseId) {
            cell = reusableCell
        } else {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: reuseId)
        }
        
        if let studentInformation: StudentInformation = allStudentInformation[indexPath.row] {
            cell.textLabel!.text =  studentInformation.fullName
            cell.detailTextLabel!.text = studentInformation.mediaURL
            cell.detailTextLabel!.textColor = UIColor.lightGrayColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let studentInformation: StudentInformation = allStudentInformation[indexPath.row] {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: studentInformation.mediaURL)!)
        }
    }
    
}











