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
            getUdacitySessionID([HTTPBodyKeys.Username: loginVC.emailTextField.text!, HTTPBodyKeys.Password: loginVC.passwordTextField.text!]) { success, sessionID, errorString in
                
                if success {
                    self.sessionID = sessionID
                }
                
                completionHandler(success: success, errorString: errorString)
            }
        }
        
    }
    
    func getUdacitySessionID(parameters: [String: String], completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        let httpBodyString = "{\"\(HTTPBodyKeys.Udacity)\": {\"\(HTTPBodyKeys.Username)\": \"<\(HTTPBodyKeys.Username)>\", \"\(HTTPBodyKeys.Password)\": \"<\(HTTPBodyKeys.Password)>\"}}"
        let httpBody = UdacityClient.substitutedHTTPBody(httpBodyString, parameters: parameters)
        
        startTaskForUdacityPOSTMethod(Methods.Session, httpBody: httpBody) { result, error in
            
            guard error == nil else {
                print("Login Failed. Error: \(error)")
                completionHandler(success: false, sessionID: nil, errorString: error!.description)
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, sessionID: nil, errorString: "No result returned.")
                return
            }
            
            guard let session = result[JSONResponseKeys.Session] as? [String: String] else {
                completionHandler(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                return
            }
            
            let sessionID = session[JSONResponseKeys.ID]
            completionHandler(success: true, sessionID: sessionID, errorString: nil)
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
            completionHandler(success: true, studentLocations: studentLocations, errorString: nil)
        }
    }
    
}









