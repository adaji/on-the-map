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

        let jsonBody = [UdacityClient.JSONBodyKeys.FacebookMobile: [UdacityClient.JSONBodyKeys.AccessToken: accessToken]]
        postSession(jsonBody, completionHandler: completionHandler)
    }
    
    // POSTing (Creating) a Session
    func postSession(jsonBody: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        startTaskForUdacityPOSTMethod(Methods.Session, jsonBody: jsonBody) { result, error in
            
            guard error == nil else {
                print("Login Failed. Error: \(error)")
                completionHandler(success: false, errorString: error!.description)
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, errorString: "Login Failed (Session ID).")
                return
            }
            
            guard let session = result[JSONResponseKeys.Session] as? [String: String] else {
                print("Could not find key \"\(JSONResponseKeys.Session)\" in \(result)")
                completionHandler(success: false, errorString: "Login Failed (Session ID).")
                return
            }
            
            let sessionID = session[JSONResponseKeys.SessionID]
            
            guard let account = result[JSONResponseKeys.Account] as? [String: AnyObject] else {
                print("Could not find key \"\(JSONResponseKeys.Account)\" in \(result)")
                completionHandler(success: false, errorString: "Login Failed (User ID).")
                return
            }
            
            guard let userID = account[JSONResponseKeys.AccountKey] as? String else {
                print("Could not find key \"\(JSONResponseKeys.AccountKey)\" in \(account)")
                completionHandler(success: false, errorString: "Login Failed (User ID).")
                return
            }
            
            self.sessionID = sessionID
            self.userID = Int(userID)
            
            completionHandler(success: true, errorString: nil)
        }
    }
    
    // Function: deleteSession
    //
    // DELETEing (Logging Out Of) a Session
    // Method: session
    //
    func deleteSession(completionHandler: (success: Bool, errorString: String?) -> Void) {
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









