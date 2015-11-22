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
    
    @IBOutlet weak var tableView: UITableView!
    
    var allStudentInformation = [StudentInformation]()
    
    // MARK: Show AllStudentInformation (Override)
    
    override func showAllStudentInformation(allStudentInformation: [StudentInformation]) {
        super.showAllStudentInformation(allStudentInformation)
        
        self.allStudentInformation = allStudentInformation
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
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
        
        var cell: StudentInformationCell
        if let reusableCell = tableView.dequeueReusableCellWithIdentifier(reuseId) as? StudentInformationCell {
            cell = reusableCell
        } else {
            cell = StudentInformationCell(style: .Subtitle, reuseIdentifier: reuseId)
        }
        
        if let studentInformation: StudentInformation = allStudentInformation[indexPath.row] {
            cell.configureCell(studentInformation.initials(), name: studentInformation.fullName(), location: studentInformation.mapString, urlString: studentInformation.mediaURL)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let studentInformation: StudentInformation = allStudentInformation[indexPath.row] {
            openURL(studentInformation.mediaURL)
        }
    }
    
}











