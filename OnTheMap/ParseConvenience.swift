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
    
    // MARK: Student Information Data
    
    // Function: getStudentInformationDictionaries
    //
    // GET an array of StudentInformation dictionaries
    // Optional parameters: ["limit": 100, "skip": 400, "order": -updatedAt]
    func getStudentInformationData(completionHandler: (success: Bool, studentInformationDictionaries: [[String: AnyObject]]?, errorString: String?) -> Void) {
        let optionalParameters = [ParseClient.ParameterKeys.LimitKey: 100, ParseClient.ParameterKeys.SkipKey: 0, ParseClient.ParameterKeys.OrderKey: "-updatedAt"]
        startTaskForGETMethod(nil, parameters: optionalParameters) { (result, error) -> Void in
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, studentInformationDictionaries: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, studentInformationDictionaries: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let studentInformationDictionaries = result[JSONResponseKeys.Results] as? [[String: AnyObject]] else {
                print("Could not find key \(JSONResponseKeys.Results) in \(result)")
                completionHandler(success: false, studentInformationDictionaries: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            completionHandler(success: true, studentInformationDictionaries: studentInformationDictionaries, errorString: nil)
        }
    }
    
    // Submit student information
    // If user has posted information before, update the information
    // If not, post it
    func submitStudentInformation(update: Bool, dictionary: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        if update {
            updateStudentInformation(dictionary, completionHandler: completionHandler)
        }
        else {
            postStudentInformation(dictionary, completionHandler: completionHandler)
        }
    }
    
    // Function: postStudentInformation
    // Parameters:
    // - dictionary: ["uniqueKey": "<uniqueKey>", "firstName": "<firstName>", "lastName": "<lastName>", "mapString": "<mapString>", "mediaUrl": "<mediaUrl>", "latitude": "<latitude>", "longitude": "<longitude>"] (studentInformation.dictionary())
    // - completionHandler
    //
    // POST a StudentInformation
    // Required parameters (in HTTPBody): parameters
    //
    func postStudentInformation(dictionary: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        startTaskForPOSTMethod(dictionary) { (result, error) -> Void in
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
    // - dictionary: ["objectId": "<objectId>", "uniqueKey": "<uniqueKey>", "firstName": "<firstName>", "lastName": "<lastName>", "mapString": "<mapString>", "mediaUrl": "<mediaUrl>", "latitude": "<latitude>", "longitude": "<longitude>"] (studentInformation.dictionary())
    // - completionHandler
    //
    // PUT a StudentInformation
    // Required parameters (in HTTPBody): parameters
    //
    func updateStudentInformation(dictionary: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        let method = substituteKeyInMethod(Methods.UpdateStudentInformation, key: URLKeys.ObjectId, value: dictionary[StudentInformation.Keys.ObjectId] as! String)
        startTaskForPUTMethod(method, jsonBody: dictionary) { (result, error) -> Void in
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
    // Query for (GET) a StudentInformation
    // Required parameters: [where: "\"uniqueKey\":\"<uniqueKey>\""]
    //
    func queryForStudentInformation(completionHandler: (success: Bool, studentInformationDictionary: [String: AnyObject]?, errorString: String?) -> Void) {
        let parameters = [ParseClient.ParameterKeys.WhereKey: "{\"\(ParseClient.ParameterKeys.UniqueKey)\":\"\(UdacityClient.sharedInstance().userID!)\"}"]
        startTaskForGETMethod(nil, parameters: parameters) { (result, error) -> Void in
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, studentInformationDictionary: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, studentInformationDictionary: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            guard let results = result[JSONResponseKeys.Results] as? [[String: AnyObject]] else {
                print("Could not find key \(JSONResponseKeys.Results) in \(result).")
                completionHandler(success: false, studentInformationDictionary: nil, errorString: "There was an error retrieving student data.")
                return
            }
            
            completionHandler(success: true, studentInformationDictionary: results[0], errorString: nil)
        }
    }
    
    // Function: searchForStudentInformation
    //
    // Search for an array of StudentInformation
    // Required parameters:
    // - ?
    //
    // TODO: To implement
    // Need search API
    func searchForStudentInformationData(completeHandler: (success: Bool, studentInformationDictionaries: [[String: AnyObject]]?, errorString: String?) -> Void) -> NSURLSessionDataTask {
        return startTaskForGETMethod("", parameters: [String: AnyObject](), completionHandler: { (result, error) -> Void in
            // Handle search result
        })
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