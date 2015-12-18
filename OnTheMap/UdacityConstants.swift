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
        // URLs
        static let BaseURL: String = "https://www.udacity.com/api/"
        static let SigninURL: String = "https://www.udacity.com/account/auth#!/signin"
    }
    
    struct Methods {
        static let Session = "session"
        static let UserData = "users/<userId>" // GETting Public User Data
    }
    
    struct URLKeys {
        static let UserId = "userId"
    }

    struct JSONBodyKeys {
        // MARK: Udacity Auth
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"

        // MARK: Facebook Auth
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken = "access_token"
    }
    
    struct JSONResponseKeys {
        // MARK: Udacity Session
        
        // User id
        static let Account = "account"
        static let AccountKey = "key"

        // Session id
        static let Session = "session"
        static let SessionID = "id"
        
        // MARK: Udacity User
        
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        
    }
    
}
