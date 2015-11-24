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
        startTaskForPOSTMethod(.Udacity, method: Methods.Session, jsonBody: jsonBody) { result, error in
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
        startTaskForDELETEMethod(.Udacity, method: Methods.Session) { (result, error) -> Void in
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
    // TODO: Find its usage
    func getUserDictionary(userId: String, completionHandler: (success: Bool, userDictionary: [String: AnyObject]?, errorString: String?) -> Void) {
        let method = UdacityClient.substituteKeyInMethod(Methods.UserData, key: UdacityClient.URLKeys.UserId, value: userId)
        startTaskForGETMethod(.Udacity, method: method, parameters: nil) { (result, error) -> Void in
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
            
            print("user dictionary: \(user)")
            completionHandler(success: true, userDictionary: user, errorString: nil)
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
        startTaskForGETMethod(.Parse, method: nil, parameters: optionalParameters) { (result, error) -> Void in
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
            completionHandler(success: true, allStudentInformation: allStudentInformation, errorString: nil)
        }
    }
    
    // Submit StudentInformation
    // If user has posted information before, update the information
    // If not, post it
    func submitStudentInformation(objectId: String, informationDictionary: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        if objectId.isEmpty {
            postStudentInformation(informationDictionary, completionHandler: completionHandler)
        }
        else {
            updateStudentInformation(objectId, informationDicationary: informationDictionary, completionHandler: completionHandler)
        }
    }
    
    // Function: postStudentInformation
    // Parameters:
    // - informationDictionary: ["uniqueKey": "<uniqueKey>", "firstName": "<firstName>", "lastName": "<lastName>", "mapString": "<mapString>", "mediaURL": "<mediaURL>", "latitude": "<latitude>", "longitude": "<longitude>"] (studentInformation.dictionary())
    // - completionHandler
    //
    // POSTing a StudentInformation
    // Required parameters (in HTTPBody): parameters
    //
    func postStudentInformation(informationDictionary: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        startTaskForPOSTMethod(.Parse, method: nil, jsonBody: informationDictionary) { (result, error) -> Void in
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
    // - informationDictionary: ["uniqueKey": "<uniqueKey>", "firstName": "<firstName>", "lastName": "<lastName>", "mapString": "<mapString>", "mediaURL": "<mediaURL>", "latitude": "<latitude>", "longitude": "<longitude>"] (studentInformation.dictionary())
    // - completionHandler
    //
    // PUTting a StudentInformation
    // Required parameters (in HTTPBody): parameters
    //
    func updateStudentInformation(objectId: String, informationDicationary: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        let method = UdacityClient.substituteKeyInMethod(Methods.UpdateStudentInformation, key: URLKeys.ObjectId, value: objectId)
        startTaskForPUTMethod(.Parse, method: method, jsonBody: informationDicationary) { (result, error) -> Void in
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, errorString: "There was an error updating student data.")
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, errorString: "There was an error updating student data.")
                return
            }
            
            print("Update student information succeed. Result: \(result))")
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
        startTaskForGETMethod(.Parse, method: nil, parameters: parameters) { (result, error) -> Void in
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
            completionHandler(success: true, studentInformation: studentInformation, errorString: nil)
        }
    }
    
}









