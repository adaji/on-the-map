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
        
    // MARK: Show AllStudentInformation (Override)
    
    override func showAllStudentInformation() {
        super.showAllStudentInformation()
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    // MARK: Actions
    
    // Add user as a friend/peer/...
    // TODO: Implement when required API comes out :)
    func addFriend(sender: UIButton) {
        if let studentInformation: StudentInformation = model.allStudentInformation![sender.tag] {
            showAlert("Add \(studentInformation.fullName()) as a friend")
        }
    }
    
    // Start a conversation with user
    // TODO: Implement when required API comes out :)
    func startConversation(sender: UIButton) {
        if let studentInformation: StudentInformation = model.allStudentInformation![sender.tag] {
            showAlert("Start a conversation with \(studentInformation.fullName())")
        }
    }
    
}

// MARK: - ListViewController: UITableViewDataSource, UITableViewDelegate

extension ListViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.allStudentInformation!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId = "StudentInformationCell"
        
        var cell: StudentInformationCell
        if let reusableCell = tableView.dequeueReusableCellWithIdentifier(reuseId) as? StudentInformationCell {
            cell = reusableCell
        } else {
            cell = StudentInformationCell(style: .Subtitle, reuseIdentifier: reuseId)
        }
        
        if let studentInformation: StudentInformation = model.allStudentInformation?[indexPath.row] {
            cell.configureCell(studentInformation.initials(), name: studentInformation.fullName(), location: studentInformation.mapString, urlString: studentInformation.mediaURL)
            
            cell.addButton.tag = indexPath.row // Add tag to identify which add button is pressed
            cell.addButton.addTarget(self, action: "addFriend:", forControlEvents: .TouchUpInside)
            
            cell.chatButton.tag = indexPath.row
            cell.chatButton.addTarget(self, action: "startConversation:", forControlEvents: .TouchUpInside)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let studentInformation: StudentInformation = model.allStudentInformation?[indexPath.row] {
            openURL(studentInformation.mediaURL)
        }
    }
    
}











