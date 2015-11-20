//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/18/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import Foundation

// MARK: - UdacityClient (Convenient Resource Methods)

extension UdacityClient {
    
    // MARK: Udacity Authetication Methods
    
    func autheticateUdacityWithViewController(hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        if let loginVC = hostViewController as? LoginViewController {
            getUdacitySessionID([HTTPBodyKeys.Username: loginVC.emailTextField.text!, HTTPBodyKeys.Password: loginVC.passwordTextField.text!]) { success, sessionID, userID, errorString in
                
                if success {
                    if let sessionID = sessionID {
                        self.sessionID = sessionID
                    }
                    if let userID = userID {
                        self.userID = Int(userID)
                    }
                }
                
                completionHandler(success: success, errorString: errorString)
            }
        }
        
    }
    
    func getUdacitySessionID(parameters: [String: String], completionHandler: (success: Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
        
        let httpBodyString = "{\"\(HTTPBodyKeys.Udacity)\": {\"\(HTTPBodyKeys.Username)\": \"<\(HTTPBodyKeys.Username)>\", \"\(HTTPBodyKeys.Password)\": \"<\(HTTPBodyKeys.Password)>\"}}"
        let httpBody = UdacityClient.substituteKeysInHTTPBody(httpBodyString, parameters: parameters)
        
        startTaskForUdacityPOSTMethod(Methods.Session, httpBody: httpBody) { result, error in
            
            guard error == nil else {
                print("Login Failed. Error: \(error)")
                completionHandler(success: false, sessionID: nil, userID: nil, errorString: error!.description)
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, sessionID: nil, userID: nil, errorString: "No result returned.")
                return
            }
            
            guard let session = result[JSONResponseKeys.Session] as? [String: String] else {
                completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID).")
                return
            }
            
            let sessionID = session[JSONResponseKeys.SessionID]
            
            guard let account = result[JSONResponseKeys.Account] as? [String: AnyObject] else {
                print("Could not find key \(JSONResponseKeys.Account)")
                completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (User ID).")
                return
            }
            
            guard let userID = account[JSONResponseKeys.AccountKey] as? String else {
                print("Could not get user id")
                completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (User ID).")
                return
            }
            
            completionHandler(success: true, sessionID: sessionID, userID: userID, errorString: nil)
        }
    }
    
    func deleteUdacitySession(completionHandler: (success: Bool, errorString: String?) -> Void) {
        startTaskForUdacityDELETEMethod(Methods.Session) { (result, error) -> Void in
            
            guard error == nil else {
                print("Logout Failed. Error: \(error)")
                completionHandler(success: false, errorString: "Logout Failed (Delete Session).")
                return
            }
            
            completionHandler(success: true, errorString: nil)
        }
    }
    
    func getUdacityPublicUserData(completionHandler: (success: Bool, udacityUser: UdacityUser?, errorString: String?) -> Void) {
        let method = UdacityClient.substituteKeyInMethod(Methods.UserData, key: URLKeys.UserId, value: String(UdacityClient.sharedInstance().userID!))
        
        startTaskForUdacityGETMethod(method) { (result, error) -> Void in
            
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, udacityUser: nil, errorString: error!.description)
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, udacityUser: nil, errorString: "No result returned.")
                return
            }
            
            guard let user = result[JSONResponseKeys.User] as? [String: AnyObject] else {
                print("No valid data returned.")
                completionHandler(success: false, udacityUser: nil, errorString: "Could not find key \(JSONResponseKeys.User) in \(result)")
                return
            }
            
            let udacityUser = UdacityUser(dictionary: user)
            self.udacityUser = udacityUser
            completionHandler(success: true, udacityUser: udacityUser, errorString: nil)
        }
    }
    
    // MARK: Student Locations
    
    func getStudentLocations(parameters: [String: AnyObject], completionHandler: (success: Bool, studentLocations: [StudentLocation]?, errorString: String?) -> Void) {
        
        startTaskForParseGETMethod(parameters) { (result, error) -> Void in
            
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, studentLocations: nil, errorString: error!.description)
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, studentLocations: nil, errorString: "No result returned.")
                return
            }
            
            guard let results = result[JSONResponseKeys.Results] as? [[String: AnyObject]] else {
                print("No valid data returned.")
                completionHandler(success: false, studentLocations: nil, errorString: "Could not find key \(JSONResponseKeys.Results) in \(result)")
                return
            }
            
            let studentLocations = StudentLocation.locationsFromResults(results)
            self.studentLocations = studentLocations
            completionHandler(success: true, studentLocations: studentLocations, errorString: nil)
        }
    }
    
}









