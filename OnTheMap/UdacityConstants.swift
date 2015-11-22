//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/18/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

// MARK: - UdacityClient (Constants)

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        static let ParseAppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr" // Parse Application ID
        static let ParseAPIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY" // Parse REST API Key
        static let FacebookAppID = "365362206864879" // Facebook App ID
        static let FacebookURLSchemeSuffix = "onthemap" // Udacity Facebook URL Scheme Suffix
        
        static let UdacityBaseURL: String = "https://www.udacity.com/api/"
        static let ParseBaseURL: String = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    struct HTTPMethods {
        
        static let POST = "POST"
        static let GET = "GET"
        static let DELETE = "DELETE"
        static let PUT = "PUT"
    }
    
    struct Methods {
        
        // Udacity
        static let Session = "session"
        static let UserData = "users/<userId>" // GETting Public User Data
        
        // Parse
        static let UpdateStudentLocation = "<objectId>" // PUTing (Updating) a StudentLocation
    }
    
    struct URLKeys {
        
        static let UserId = "userId"
        static let ObjectId = "objectId"
    }
    
    struct ParameterKeys {
        
        // Get Student Locations (Optional)
        static let LimitKey = "limit" // (Number) specifies the maximum number of StudentLocation objects to return in the JSON response
        static let SkipKey = "skip" // (Number) use this parameter with limit to paginate through results
        static let OrderKey = "order" // (String) a comma-separate list of key names that specify the sorted order of the results
        
        // Get Student Location (Required)
        static let WhereKey = "where"
        static let UniqueKey = "uniqueKey" // Udacity user id
    }
    
    struct HTTPHeaderKeys {
        
        static let ParseAppIdKey = "X-Parse-Application-Id"
        static let ParseAPIKey = "X-Parse-REST-API-Key"
    }
    
    struct HTTPBodyKeys {
        
        // Udacity Auth
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        
        // Facebook Auth
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken = "access_token"
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
    
    struct StudentLocationKeys {
        
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
        
        // Udacity Session
        
        // User id
        static let Account = "account"
        static let AccountKey = "key"

        // Session id
        static let Session = "session"
        static let SessionID = "id"
        
        // Student Location(s)
        
        static let Results = "results"
        
        static let LocationObjectId = "objectId"
        static let LocationUniqueKey = "uniqueKey"
        static let LocationFirstName = "firstName"
        static let LocationLastName = "lastName"
        static let LocationMapString = "mapString"
        static let LocationMediaURL = "mediaURL"
        static let LocationLatitude = "latitude"
        static let LocationLongitude = "longitude"
        static let LocationCreatedAt = "createdAt"
        static let LocationUpdatedAt = "updatedAt"
        
        // Udacity User
        
        static let User = "user"

        static let UserFirstName = "first_name"
        static let UserLastName = "last_name"
        static let UserLocation = "location"
        static let UserWebsiteUrl = "website_url"
    }
    
}
