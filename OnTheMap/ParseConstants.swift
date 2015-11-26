//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/24/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation

// MARK: - ParseClient (Constants)

extension ParseClient {
    
    struct Constants {
        static let AppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr" // Parse Application ID
        static let APIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY" // Parse REST API Key

        static let BaseURL: String = "https://api.parse.com/1/classes/StudentLocation/" // Add "/" at the end of base URL for appending methods
    }
    
    struct Methods {
        static let UpdateStudentInformation = "<objectId>" // PUTing (Updating) a StudentInformation
    }
    
    struct URLKeys {
        static let ObjectId = "objectId"
    }
    
    struct ParameterKeys {
        // Get StudentInformationArray (Optional)
        static let LimitKey = "limit" // (Number) specifies the maximum number of StudentInformation objects to return in the JSON response
        static let SkipKey = "skip" // (Number) use this parameter with limit to paginate through results
        static let OrderKey = "order" // (String) a comma-separate list of key names that specify the sorted order of the results
        
        // Get StudentInformation (Required)
        static let WhereKey = "where"
        static let UniqueKey = "uniqueKey" // Udacity user id
    }
    
    struct HTTPHeaderKeys {
        static let ParseAppIdKey = "X-Parse-Application-Id"
        static let ParseAPIKey = "X-Parse-REST-API-Key"
    }
    
    struct JSONResponseKeys {
        // (All) Student Information
        static let Results = "results"
    }
    
}









