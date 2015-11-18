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
    
    // MARK: Authetication (GET) Methods
    
    func autheticateWithViewController(hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        if let loginVC = hostViewController as? LoginViewController {
            getSessionID([HTTPBodyKeys.Username: loginVC.emailTextField.text!, HTTPBodyKeys.Password: loginVC.passwordTextField.text!]) { success, sessionID, errorString in
                
                if success {
                    self.sessionID = sessionID
                }
                
                completionHandler(success: success, errorString: errorString)
            }
        }
        
    }
    
    func getSessionID(parameters: [String: String], completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        let httpBodyString = "{\"\(HTTPBodyKeys.Udacity)\": {\"\(HTTPBodyKeys.Username)\": \"<\(HTTPBodyKeys.Username)>\", \"\(HTTPBodyKeys.Password)\": \"<\(HTTPBodyKeys.Password)>\"}}"
        let httpBody = UdacityClient.substitutedHTTPBody(httpBodyString, parameters: parameters)
        
        startTaskForPOSTMethod(Methods.Session, httpBody: httpBody) { result, error in
            
            guard error == nil else {
                print("Login Failed. Error: \(error)")
                completionHandler(success: false, sessionID: nil, errorString: error!.description)
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
    
    func deleteSession(completionHandler: (success: Bool, errorString: String?) -> Void) {
        startTaskForDELETEMethod(Methods.Session) { (result, error) -> Void in
            
            guard error == nil else {
                print("Logout Failed. Error: \(error)")
                completionHandler(success: false, errorString: "Logout Failed (Delete Session).")
                return
            }
            
            completionHandler(success: true, errorString: nil)
        }
    }
    
}









