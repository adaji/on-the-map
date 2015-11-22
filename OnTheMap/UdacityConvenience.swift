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
    func getUdacityUser(userId: String, completionHandler: (success: Bool, udacityUser: UdacityUser?, errorString: String?) -> Void) {
        let method = UdacityClient.substituteKeyInMethod(Methods.UserData, key: UdacityClient.URLKeys.UserId, value: userId)
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
            
            print("user dictionary: \(user)")
            let udacityUser = UdacityUser(dictionary: user)
            completionHandler(success: true, udacityUser: udacityUser, errorString: nil)
        }
    }
    
    // MARK: (All) Student Information
    
    // Function: getAllStudentInformation
    // Parameters:
    // - optionalParameters: ["limit": 100, "skip": 400, "order": -updatedAt]
    // - completionHandler
    //
    // GETting an array of StudentInformation
    // Optional parameters: "limit", "skip", "order"
    func getAllStudentInformation(optionalParameters: [String: AnyObject]?, completionHandler: (success: Bool, allStudentInformation: [StudentInformation]?, errorString: String?) -> Void) {
        startTaskForParseGETMethod(optionalParameters) { (result, error) -> Void in
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, allStudentInformation: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, allStudentInformation: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let results = result[JSONResponseKeys.Results] as? [[String: AnyObject]] else {
                print("Could not find key \(JSONResponseKeys.Results) in \(result)")
                completionHandler(success: false, allStudentInformation: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            let allStudentInformation = StudentInformation.allStudentInformationFromResults(results)
            self.allStudentInformation = allStudentInformation
            completionHandler(success: true, allStudentInformation: allStudentInformation, errorString: nil)
        }
    }
    
    // Submit StudentInformation
    // If user has posted location before, update the location
    // If not, post it
    func submitStudentInformation(hasPosted: Bool, locationDictionary: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        if hasPosted {
            // TODO: Check if there is a bug
            // Somehow updateStudentInformation doesn't update user's location returned in getStudentInformationArray
            // Let's use postStudentInformation for now
            // updateStudentInformation(locationDictionary, completionHandler: completionHandler)
            postStudentInformation(locationDictionary, completionHandler: completionHandler)
        }
        else {
            postStudentInformation(locationDictionary, completionHandler: completionHandler)
        }
    }
    
    // Function: postStudentInformation
    // Parameters:
    // - locationDictionary: ["uniqueKey": "<uniqueKey>", "firstName": "<firstName>", "lastName": "<lastName>", "mapString": "<mapString>", "mediaURL": "<mediaURL>", "latitude": "<latitude>", "longitude": "<longitude>"] (studentInformation.dictionary())
    // - completionHandler
    //
    // POSTing a StudentInformation
    // Required parameters (in HTTPBody): parameters
    //
    func postStudentInformation(locationDictionary: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        startTaskForParsePOSTMethod(locationDictionary) { (result, error) -> Void in
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, errorString: "There was an error posting student data.")
                return
            }
            
            completionHandler(success: true, errorString: nil)
        }
    }
    
    // Function: updateStudentInformation
    // Parameters:
    // - locationDictionary: ["uniqueKey": "<uniqueKey>", "firstName": "<firstName>", "lastName": "<lastName>", "mapString": "<mapString>", "mediaURL": "<mediaURL>", "latitude": "<latitude>", "longitude": "<longitude>"] (studentInformation.dictionary())
    // - completionHandler
    //
    // PUTting a StudentInformation
    // Required parameters (in HTTPBody): parameters
    //
    func updateStudentInformation(locationDicationary: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        let method = UdacityClient.substituteKeyInMethod(Methods.UpdateStudentInformation, key: URLKeys.ObjectId, value: UdacityClient.sharedInstance().userID!)
        startTaskForParsePUTMethod(method, jsonBody: locationDicationary) { (result, error) -> Void in
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, errorString: "There was an error updating student data.")
                return
            }
            
            completionHandler(success: true, errorString: nil)
        }
    }
    
    // Function: queryForStudentInformation
    // Parameters:
    // - parameters: [where: "\"uniqueKey\":\"<uniqueKey>\""]
    // - completionHandler
    //
    // Querying for a StudentInformation
    // Required parameters: "where"
    //
    func queryForStudentInformation(parameters: [String: AnyObject], completionHandler: (success: Bool, studentInformation: StudentInformation?, errorString: String?) -> Void) {
        startTaskForParseGETMethod(parameters) { (result, error) -> Void in
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, studentInformation: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, studentInformation: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let results = result[JSONResponseKeys.Results] as? [[String: AnyObject]] else {
                print("Could not find key \(JSONResponseKeys.Results) in \(result).")
                completionHandler(success: false, studentInformation: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            let studentInformation = StudentInformation(dictionary: results[0])
            self.myStudentInformation = studentInformation
            completionHandler(success: true, studentInformation: studentInformation, errorString: nil)
        }
    }
    
}









