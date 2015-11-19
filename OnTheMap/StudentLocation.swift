//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/18/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation

struct StudentLocation {
    
    // MARK: Properties
    
    var objectId = ""
    var uniqueKey = ""
    var fullName = ""
    var mapString = ""
    var mediaURL = ""
    var latitude = 0.0
    var longitude = 0.0
    var createdAt: NSDate
    var updatedAt: NSDate
    
    // MARK: Initializers
    
    init(dictionary: [String: AnyObject]) {
        
        objectId = dictionary[UdacityClient.JSONResponseKeys.ObjectId] as! String
        uniqueKey = dictionary[UdacityClient.JSONResponseKeys.UniqueKey] as! String // Udacity account (user) id
        let firstName = dictionary[UdacityClient.JSONResponseKeys.FirstName] as! String
        let lastName = dictionary[UdacityClient.JSONResponseKeys.LastName] as! String
        fullName = "\(firstName) \(lastName)"
        mapString = dictionary[UdacityClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[UdacityClient.JSONResponseKeys.MediaURL] as! String
        latitude = dictionary[UdacityClient.JSONResponseKeys.Latitude] as! Double
        longitude = dictionary[UdacityClient.JSONResponseKeys.Longitude] as! Double
        
        // Parse date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let createdAtString = dictionary[UdacityClient.JSONResponseKeys.CreatedAt] as! String
        createdAt = dateFormatter.dateFromString(createdAtString)!
        let updatedAtString = dictionary[UdacityClient.JSONResponseKeys.UpdatedAt] as! String
        updatedAt = dateFormatter.dateFromString(updatedAtString)!
    }
    
    // Given an array of dictionaries, convert them to an array of StudentLocation objects
    static func locationsFromResults(results: [[String: AnyObject]]) -> [StudentLocation] {
        var locations = [StudentLocation]()
        
        for result in results {
            locations.append(StudentLocation(dictionary: result))
        }
        
        return locations
    }
}









