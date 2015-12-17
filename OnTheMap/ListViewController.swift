//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD

// MARK: - ListViewController: CommonViewController

class ListViewController: CommonViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Life Cycle
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if fetchedResultsController.fetchedObjects!.isEmpty {
            fetchAndShowAllStudentInformation()
        }
    }
    
    // MARK: Show All Student Information (Override)
    
    // Show all student information on map
    //
    // Note: implement this method here to avoid re-implementing the refresh method
    // which is extracted in the CommonViewController and uses this method which cannot be extracted
    override func showAllStudentInformation() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        })
    }
    
    // MARK: Actions
    
    // Add user as a friend/peer/...
    // TODO: Implement when required API comes out :)
    func addFriend(sender: UIButton) {
        if let studentInformation = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as? StudentInformation {
            showAlert("Add \(studentInformation.fullName()) as a friend")
        }
    }
    
    // Start a conversation with user
    // TODO: Implement when required API comes out :)
    func startConversation(sender: UIButton) {
        if let studentInformation = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as? StudentInformation {
            showAlert("Start a conversation with \(studentInformation.fullName())")
        }
    }
    
}

// MARK: - ListViewController (NSFetchedResultsControllerDelegate)

extension ListViewController {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        tableView.endUpdates()
    }
    
}

// MARK: - ListViewController: UITableViewDataSource, UITableViewDelegate

extension ListViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let nRows = fetchedResultsController.sections![section].numberOfObjects
        print("number of rows: \(nRows)")
        return nRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId = "StudentInformationCell"
        
        var cell: StudentInformationCell
        if let reusableCell = tableView.dequeueReusableCellWithIdentifier(reuseId) as? StudentInformationCell {
            cell = reusableCell
        } else {
            cell = StudentInformationCell(style: .Subtitle, reuseIdentifier: reuseId)
        }
        
        let studentInformation = fetchedResultsController.objectAtIndexPath(indexPath) as! StudentInformation
        cell.configureCell(studentInformation.initials(), name: studentInformation.fullName(), location: studentInformation.mapString, urlString: studentInformation.mediaUrl)
        
        cell.addButton.tag = indexPath.row // Add tag to identify which add button is pressed
        cell.addButton.addTarget(self, action: "addFriend:", forControlEvents: .TouchUpInside)
        
        cell.chatButton.tag = indexPath.row
        cell.chatButton.addTarget(self, action: "startConversation:", forControlEvents: .TouchUpInside)
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let studentInformation = fetchedResultsController.objectAtIndexPath(indexPath) as! StudentInformation
        openURL(studentInformation.mediaUrl)
    }
    
}











