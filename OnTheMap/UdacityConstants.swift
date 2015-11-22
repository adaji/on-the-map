//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/18/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

// MARK: - UdacityClient (Constants)

extension UdacityClient {
    
    struct Constants {
        static let ParseAppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr" // Parse Application ID
        static let ParseAPIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY" // Parse REST API Key
        
        // URLs
        static let UdacityBaseURL: String = "https://www.udacity.com/api/"
        static let ParseBaseURL: String = "https://api.parse.com/1/classes/StudentLocation"
        static let UdacitySigninURL: String = "https://www.udacity.com/account/auth#!/signin"
    }
    
    struct HTTPMethods {
        static let POST = "POST"
        static let GET = "GET"
        static let DELETE = "DELETE"
        static let PUT = "PUT"
    }
    
    struct Methods {
        // Udacity methods
        static let Session = "session"
        static let UserData = "users/<userId>" // GETting Public User Data
        
        // Parse methods
        static let UpdateStudentInformation = "<objectId>" // PUTing (Updating) a StudentInformation
    }
    
    struct URLKeys {
        static let UserId = "userId"
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
    
    struct JSONBodyKeys {
        // Udacity Auth
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        
        // Facebook Auth
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken = "access_token"
    }
    
    struct StudentInformationKeys {
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
    }
    
    struct JSONResponseKeys {
        // MARK: Udacity Session
        
        // User id
        static let Account = "account"
        static let AccountKey = "key"

        // Session id
        static let Session = "session"
        static let SessionID = "id"
        
        // MARK: (All) Student Information
        
        static let Results = "results"
        
        // MARK: Udacity User
        
        static let User = "user"

        static let UserFirstName = "first_name"
        static let UserLastName = "last_name"
        static let UserLocation = "location"
        static let UserWebsiteUrl = "website_url"
    }
    
}
