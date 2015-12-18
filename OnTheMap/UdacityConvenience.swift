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
    
    // Function: authenticate
    // Parameters:
    // - username
    // - password
    // - completionHandler
    //
    // POSTing (Creating) a Session
    // Method: session
    // Required parameters (in HTTPBody): ["udacity": ["username": username, "password": password]]
    //
    func authenticate(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let jsonBody = [UdacityClient.JSONBodyKeys.Udacity: [UdacityClient.JSONBodyKeys.Username: username, UdacityClient.JSONBodyKeys.Password: password]]
        postSession(jsonBody, completionHandler: completionHandler)
    }
    
    // Function: loginWithFacebook
    // Parameters:
    // - accessToken
    // - completionHandler
    //
    // POSTing (Creating) a Session with Facebook Authentication
    // Method: session
    // Required parameters (in HTTPBody): ["facebook_mobile": ["access_token": accessToken]]
    //
    func loginWithFacebook(accessToken: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let jsonBody = [JSONBodyKeys.FacebookMobile: [JSONBodyKeys.AccessToken: accessToken]]
        postSession(jsonBody, completionHandler: completionHandler)
    }
    
    // POSTing (Creating) a Session
    func postSession(jsonBody: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        startTaskForPOSTMethod(Methods.Session, jsonBody: jsonBody) { result, error in
            guard error == nil else {
                print("Login Failed. Error: \(error)")
                completionHandler(success: false, errorString: error!.localizedDescription)
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, errorString: "Login Failed (Session ID).")
                return
            }
            
            guard let session = result[JSONResponseKeys.Session] as? [String: AnyObject] else {
                print("Could not find key \"\(JSONResponseKeys.Session)\" in \(result)")
                completionHandler(success: false, errorString: "Login Failed (Session ID).")
                return
            }
            
            guard let account = result[JSONResponseKeys.Account] as? [String: AnyObject] else {
                print("Could not find key \"\(JSONResponseKeys.Account)\" in \(result)")
                completionHandler(success: false, errorString: "Login Failed (User ID).")
                return
            }
            
            self.sessionID = session[JSONResponseKeys.SessionID] as? String
            self.userID = account[JSONResponseKeys.AccountKey] as? String
            
            completionHandler(success: true, errorString: nil)
        }
    }
    
    // Function: deleteSession
    //
    // DELETEing (Logging Out Of) a Session
    // Method: session
    //
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
    
    // Function: getUserDictionary
    //
    // GETting Public User Data
    // Method: users/<userId>
    //
    func getUserDictionary(userId: String, completionHandler: (success: Bool, userDictionary: [String: AnyObject]?, errorString: String?) -> Void) {
        let method = substituteKeyInMethod(Methods.UserData, key: URLKeys.UserId, value: userId)
        startTaskForGETMethod(method, parameters: nil) { (result, error) -> Void in
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, userDictionary: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, userDictionary: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let user = result[JSONResponseKeys.User] as? [String: AnyObject] else {
                print("Could not find key \(JSONResponseKeys.User) in \(result).")
                completionHandler(success: false, userDictionary: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            completionHandler(success: true, userDictionary: user, errorString: nil)
        }
    }
    
    // MARK: Helper Functions
    
    // Substitute the key for the value that is contained within the method name
    func substituteKeyInMethod(method: String, key: String, value: String) -> String {
        if method.rangeOfString("<\(key)>") != nil {
            return method.stringByReplacingOccurrencesOfString("<\(key)>", withString: value)
        } else {
            return method
        }
    }
    
}









