//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/18/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

struct StudentLocation {
    
    // MARK: Properties
    
    var createdAt = ""
    var firstName = ""
    var lastName = ""
    var latitude = 0.0
    var longitude = 0.0
    var mapString = ""
    var mediaURL = ""
    var objectId = ""
    var uniqueKey = ""
    var updatedAt = ""
    
    // MARK: Initializers
    
    init(dictionary: [String: AnyObject]) {
        
        createdAt = dictionary[UdacityClient.JSONResponseKeys.CreatedAt] as! String
        firstName = dictionary[UdacityClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[UdacityClient.JSONResponseKeys.LastName] as! String
        latitude = dictionary[UdacityClient.JSONResponseKeys.Latitude] as! Double
        longitude = dictionary[UdacityClient.JSONResponseKeys.Longitude] as! Double
        mapString = dictionary[UdacityClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[UdacityClient.JSONResponseKeys.MediaURL] as! String
        objectId = dictionary[UdacityClient.JSONResponseKeys.ObjectId] as! String
        uniqueKey = dictionary[UdacityClient.JSONResponseKeys.UniqueKey] as! String
        updatedAt = dictionary[UdacityClient.JSONResponseKeys.UpdatedAt] as! String
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









