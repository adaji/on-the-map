//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/18/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class LoginViewController: KeyboardHandlingViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookLoginButton: BorderedButton!
    
    var session: NSURLSession!

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Auto login if user has logged in from this device before
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let email = userDefaults.valueForKey("email") as? String {
            emailTextField.text = email
            if let password = userDefaults.valueForKey("password") as? String {
                passwordTextField.text = password
                
                login()
            }
        }
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonTouch(sender: UIButton) {
        login()
    }
    
    // MARK: Login
    
    func login() {
        // Save/update email and password
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(emailTextField.text!, forKey: "email")
        userDefaults.setValue(passwordTextField.text!, forKey: "password")
        userDefaults.synchronize()
        
        UdacityClient.sharedInstance().autheticateWithViewController(self) {
            success, errorString in
            if success {
                self.completeLogin()
            } else {
                print(errorString)
            }
        }
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            let mainNV = self.storyboard!.instantiateViewControllerWithIdentifier("MainNavigationController") as! UINavigationController
            self.presentViewController(mainNV, animated: true, completion: nil)
        })
    }

}














