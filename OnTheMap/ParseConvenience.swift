//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/24/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation

// MARK: - ParseClient (Convenient Resource Methods)

extension ParseClient {
    
    // MARK: (All) Student Information
    
    // Function: getAllStudentInformation
    //
    // GETting an array of StudentInformation
    // Optional parameters: ["limit": 100, "skip": 400, "order": -updatedAt]
    func getAllStudentInformation(completionHandler: (success: Bool, allStudentInformation: [StudentInformation]?, errorString: String?) -> Void) {
        let optionalParameters = [ParseClient.ParameterKeys.LimitKey: 100, ParseClient.ParameterKeys.SkipKey: 0, ParseClient.ParameterKeys.OrderKey: "-updatedAt"]
        startTaskForGETMethod(nil, parameters: optionalParameters) { (result, error) -> Void in
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
        startTaskForPOSTMethod(informationDictionary) { (result, error) -> Void in
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
        let method = substituteKeyInMethod(Methods.UpdateStudentInformation, key: URLKeys.ObjectId, value: objectId)
        startTaskForPUTMethod(method, jsonBody: informationDicationary) { (result, error) -> Void in
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
    //
    // Querying for a StudentInformation
    // Required parameters: [where: "\"uniqueKey\":\"<uniqueKey>\""]
    //
    func queryForStudentInformation(completionHandler: (success: Bool, studentInformation: StudentInformation?, errorString: String?) -> Void) {
        let parameters = [ParseClient.ParameterKeys.WhereKey: "{\"\(ParseClient.ParameterKeys.UniqueKey)\":\"\(UdacityClient.sharedInstance().userID!)\"}"]
        startTaskForGETMethod(nil, parameters: parameters) { (result, error) -> Void in
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