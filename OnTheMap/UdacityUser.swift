//
//  UdacityUser.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/20/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation

struct UdacityUser {
    
    var fullName = ""
    var loctaion: String?
    var websiteUrl: String?
    
    init(dictionary: [String: AnyObject]) {
        
        let firstName = dictionary[UdacityClient.JSONResponseKeys.UserFirstName] as! String
        let lastName = dictionary[UdacityClient.JSONResponseKeys.UserLastName] as! String
        fullName = "\(firstName) \(lastName)"
        loctaion = dictionary[UdacityClient.JSONResponseKeys.UserLocation] as? String
        websiteUrl = dictionary[UdacityClient.JSONResponseKeys.UserWebsiteUrl] as? String
    }
    
}