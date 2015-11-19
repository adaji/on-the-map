//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
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
    
}
