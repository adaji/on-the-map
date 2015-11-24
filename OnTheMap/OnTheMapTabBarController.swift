//
//  OnTheMapTabBarController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/24/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

// MARK: - OnTheMapTabBarController: UITabBarController
// Store data in tab bar controller to make it accessible from all view controllers

class OnTheMapTabBarController: UITabBarController {
    
     // MARK: Properties
    
    var model = OnTheMapModel() // Store student information data
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
