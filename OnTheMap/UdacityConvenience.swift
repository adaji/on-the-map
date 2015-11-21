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
            getUdacitySessionID([UdacityClient.JSONBodyKeys.Username: loginVC.emailTextField.text!, UdacityClient.JSONBodyKeys.Password: loginVC.passwordTextField.text!]) { success, sessionID, userID, errorString in
                
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
    
    // Function: getUdacitySessionID
    // Parameters: 
    // - parameters: ["username": "<username>", "password": "<password>"]
    // - completionHandler
    //
    // POSTing (Creating) a Session
    // Method: session
    // Required parameters (in HTTPBody): ["udacity": parameters]
    //
    func getUdacitySessionID(parameters: [String: String], completionHandler: (success: Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
        
        let jsonBody = [UdacityClient.JSONBodyKeys.Udacity: parameters]
        
        startTaskForUdacityPOSTMethod(Methods.Session, jsonBody: jsonBody) { result, error in
            
            guard error == nil else {
                print("Login Failed. Error: \(error)")
                var errorMessage = ""
                switch error!.code {
                case -1009:
                    errorMessage = "The Internet connection appears to be offline."
                    break
                default:
                    errorMessage = "Invalid username or password."
                    break
                }
                completionHandler(success: false, sessionID: nil, userID: nil, errorString: errorMessage)
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID).")
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
    
    // Function: deleteUdacitySession
    //
    // DELETEing (Logging Out Of) a Session
    // Method: session
    //
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
    
    // Function: getUdacityUser
    //
    // GETting Public User Data
    // Method: users/<userId>
    //
    func getUdacityUser(completionHandler: (success: Bool, udacityUser: UdacityUser?, errorString: String?) -> Void) {
        let method = UdacityClient.substituteKeyInMethod(Methods.UserData, key: URLKeys.UserId, value: String(UdacityClient.sharedInstance().userID!))
        
        startTaskForUdacityGETMethod(method) { (result, error) -> Void in
            
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, udacityUser: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, udacityUser: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let user = result[JSONResponseKeys.User] as? [String: AnyObject] else {
                print("Could not find key \(JSONResponseKeys.User) in \(result).")
                completionHandler(success: false, udacityUser: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            let udacityUser = UdacityUser(dictionary: user)
            self.udacityUser = udacityUser
            completionHandler(success: true, udacityUser: udacityUser, errorString: nil)
        }
    }
    
    // MARK: Student Location(s)
    
    // Function: getStudentLocations
    // Parameters:
    // - optionalParameters: ["limit": 100, "skip": 400, "order": -updatedAt]
    // - completionHandler
    //
    // GETting StudentLocations
    // Optional parameters: "limit", "skip", "order"
    func getStudentLocations(optionalParameters: [String: AnyObject]?, completionHandler: (success: Bool, studentLocations: [StudentLocation]?, errorString: String?) -> Void) {
        
        startTaskForParseGETMethod(optionalParameters) { (result, error) -> Void in
            
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, studentLocations: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, studentLocations: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let results = result[JSONResponseKeys.Results] as? [[String: AnyObject]] else {
                print("Could not find key \(JSONResponseKeys.Results) in \(result)")
                completionHandler(success: false, studentLocations: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            let studentLocations = StudentLocation.locationsFromResults(results)
            self.studentLocations = studentLocations
            completionHandler(success: true, studentLocations: studentLocations, errorString: nil)
        }
    }
    
    // Submit StudentLocation
    // If user has posted location before, update the location
    // If not, post it
    func submitStudentLocation(hasPosted: Bool, locationDictionary: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        if hasPosted {
            // TODO: Check if there is a bug
            // Somehow updateStudentLocation doesn't update user's location returned in getStudentLocations
            // Let's use postStudentLocation for now
            // updateStudentLocation(locationDictionary, completionHandler: completionHandler)
            postStudentLocation(locationDictionary, completionHandler: completionHandler)
        }
        else {
            postStudentLocation(locationDictionary, completionHandler: completionHandler)
        }
    }
    
    // Function: postStudentLocation
    // Parameters:
    // - locationDictionary: ["uniqueKey": "<uniqueKey>", "firstName": "<firstName>", "lastName": "<lastName>", "mapString": "<mapString>", "mediaURL": "<mediaURL>", "latitude": "<latitude>", "longitude": "<longitude>"] (StudentLocation.dictionaryFromStudentLocation(studentLocation))
    // - completionHandler
    //
    // POSTing a StudentLocation
    // Required parameters (in HTTPBody): parameters
    //
    func postStudentLocation(locationDictionary: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        startTaskForParsePOSTMethod(locationDictionary) { (result, error) -> Void in
            
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, errorString: "There was an error posting student data.")
                return
            }
            
            completionHandler(success: true, errorString: nil)
        }
    }
    
    // Function: updateStudentLocation
    // Parameters:
    // - locationDictionary: ["uniqueKey": "<uniqueKey>", "firstName": "<firstName>", "lastName": "<lastName>", "mapString": "<mapString>", "mediaURL": "<mediaURL>", "latitude": "<latitude>", "longitude": "<longitude>"] (StudentLocation.dictionaryFromStudentLocation(studentLocation))
    // - completionHandler
    //
    // PUTting a StudentLocation
    // Required parameters (in HTTPBody): parameters
    //
    func updateStudentLocation(locationDicationary: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        let method = UdacityClient.substituteKeyInMethod(Methods.UpdateStudentLocation, key: URLKeys.ObjectId, value: String(UdacityClient.sharedInstance().userID!))
        
        startTaskForParsePUTMethod(method, jsonBody: locationDicationary) { (result, error) -> Void in
            
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, errorString: "There was an error updating student data.")
                return
            }
            
            completionHandler(success: true, errorString: nil)
        }
    }
    
    // Function: queryForStudentLocation
    // Parameters:
    // - parameters: [where: "\"uniqueKey\":\"<uniqueKey>\""]
    // - completionHandler
    //
    // Querying for a StudentLocation
    // Required parameters: "where"
    //
    func queryForStudentLocation(parameters: [String: AnyObject], completionHandler: (success: Bool, studentLocation: StudentLocation?, errorString: String?) -> Void) {
        
        startTaskForParseGETMethod(parameters) { (result, error) -> Void in
            
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, studentLocation: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, studentLocation: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let results = result[JSONResponseKeys.Results] as? [[String: AnyObject]] else {
                print("Could not find key \(JSONResponseKeys.Results) in \(result).")
                completionHandler(success: false, studentLocation: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            let studentLocation = StudentLocation(dictionary: results[0])
            self.myStudentLocation = studentLocation
            completionHandler(success: true, studentLocation: studentLocation, errorString: nil)
        }
    }
    
}









