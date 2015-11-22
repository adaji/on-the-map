//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/18/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import MBProgressHUD
import FBSDKLoginKit

// MARK: - LoginViewController: KeyboardHandlingViewController

class LoginViewController: KeyboardHandlingViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
        
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setControlsEnabled(true)
        setLoginButtonEnabled(false)
        
        tryAutoLogin()
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonTouch(sender: UIButton) {
        setControlsEnabled(false)
        login()
    }
    
    // Clicking on the Sign Up link will open Safari to the Udacity sign-in page.
    @IBAction func signupButtonTouchUp(sender: UIButton) {
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
    }
    
    // MARK: Login
    
    // Try auto login
    // Login automatically if user has logged in from this device before
    func tryAutoLogin() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let email = userDefaults.valueForKey("email") as? String {
            usernameTextField.text = email
            if let password = userDefaults.valueForKey("password") as? String {
                passwordTextField.text = password
                
                if !email.isEmpty && !password.isEmpty {
                    login()
                }
            }
        }
    }
    
    func login() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Logging in..."
        
        UdacityClient.sharedInstance().authenticate(usernameTextField.text!, password: passwordTextField.text!) {
            success, errorString in
            if success {
                // Save/update email and password
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setValue(self.usernameTextField.text!, forKey: "username")
                userDefaults.setValue(self.passwordTextField.text!, forKey: "password")
                userDefaults.synchronize()
                
                self.completeLogin(false)
            } else {
                self.showLoginError(errorString)
                print(errorString)
            }
        }
    }
    
    // MARK: Configure UI
    
    func configureUI() {
        loginButton.backgroundColor = UIColor(red: 238/255.0, green: 62/255.0, blue: 10/255.0, alpha: 1.0)
        loginButton.backingColor = UIColor(red: 238/255.0, green: 62/255.0, blue: 10/255.0, alpha: 1.0)
        loginButton.highlightedBackingColor = UIColor.redColor()

        facebookLoginButton.layer.masksToBounds = true
        facebookLoginButton.layer.cornerRadius = loginButton.layer.cornerRadius
    }
    
    func setLoginButtonEnabled(enabled: Bool) {
        loginButton.enabled = enabled
        
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    func setControlsEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        setLoginButtonEnabled(enabled)
        facebookLoginButton.enabled = enabled
    }
    
    // MARK: Helper Functions
    
    // Complete login
    func completeLogin(loggedInWithFB: Bool) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).loggedInWithFB = loggedInWithFB

        dispatch_async(dispatch_get_main_queue(), {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            let mainTBC = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController // Instantiate view controller after in main queue to properly configure its UI
            mainTBC.tabBar.tintColor = UIColor.orangeColor() // Change tab bar tint color to orange
            self.presentViewController(mainTBC, animated: true, completion: nil)
        })
    }
    
    // Show login error
    func showLoginError(errorString: String?) {
        let errorString = !errorString!.isEmpty ? errorString! : "An unknow error has occurred during login."
        let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.setControlsEnabled(true)
            self.setLoginButtonEnabled(false)
        }))
        
        dispatch_async(dispatch_get_main_queue(), {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // Clear password before editing begins
        if textField == passwordTextField {
            textField.text = ""
            setLoginButtonEnabled(false)
        }
        
        return true
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Disable login button if email or password is empty
        if !usernameTextField.text!.isEmpty && !passwordTextField.text!.isEmpty && !(range.location == 0 && string == "") {
            setLoginButtonEnabled(true)
        } else {
            setLoginButtonEnabled(false)
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            setControlsEnabled(false)
            login()
        }
        
        return true
    }
    
}

// MARK: - LoginViewController: FBSDKLoginButtonDelegate

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if let error = error {
            showLoginError(error.description)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
            
            if let token = result.token {
                UdacityClient.sharedInstance().loginWithFacebook(token.tokenString) { (success, errorString) -> Void in
                    if success {
                        self.completeLogin(true)
                    } else {
                        self.showLoginError(errorString)
                    }
                }
            } else {
                showLoginError("Login failed.")
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        UdacityClient.sharedInstance().deleteSession { (success, errorString) -> Void in
            if success {
                print("Logout Succeed.")
            } else {
                print(errorString)
            }
        }
    }
    
}


















