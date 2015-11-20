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
    var uniqueKey = "" // Udacity account (user) id
    var firstName = ""
    var lastName = ""
    var fullName = ""
    var mapString = ""
    var mediaURL = ""
    var latitude = 0.0
    var longitude = 0.0
    var createdAt = NSDate()
    var updatedAt = NSDate()
    
    // MARK: Initializers
    
    init(dictionary: [String: AnyObject]) {
        
        if let objectId = dictionary[UdacityClient.StudentLocationKeys.ObjectId] as? String {
            self.objectId = objectId
        }
        if let uniqueKey = dictionary[UdacityClient.StudentLocationKeys.UniqueKey] as? String {
            self.uniqueKey = uniqueKey
        }
        if let firstName = dictionary[UdacityClient.StudentLocationKeys.FirstName] as? String {
            self.firstName = firstName
        }
        if let lastName = dictionary[UdacityClient.StudentLocationKeys.LastName] as? String {
            self.lastName = lastName
        }
        fullName = "\(firstName) \(lastName)"
        if let mapString = dictionary[UdacityClient.StudentLocationKeys.MapString] as? String {
            self.mapString = mapString
        }
        if let mediaURL = dictionary[UdacityClient.StudentLocationKeys.MediaURL] as? String {
            self.mediaURL = mediaURL
        }
        if let latitude = dictionary[UdacityClient.StudentLocationKeys.Latitude] as? Double {
            self.latitude = latitude
        }
        if let longitude = dictionary[UdacityClient.StudentLocationKeys.Longitude] as? Double {
            self.longitude = longitude
        }
        
        // Parse date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let createdAtString = dictionary[UdacityClient.StudentLocationKeys.CreatedAt] as? String {
            createdAt = dateFormatter.dateFromString(createdAtString)!
        }
        if let updatedAtString = dictionary[UdacityClient.StudentLocationKeys.UpdatedAt] as? String {
            updatedAt = dateFormatter.dateFromString(updatedAtString)!
        }
    }
    
    static func dictionaryFromStudentLocation(studentLocation: StudentLocation) -> [String: AnyObject] {
        return [
            UdacityClient.StudentLocationKeys.UniqueKey: studentLocation.uniqueKey,
            UdacityClient.StudentLocationKeys.FirstName: studentLocation.firstName,
            UdacityClient.StudentLocationKeys.LastName: studentLocation.lastName,
            UdacityClient.StudentLocationKeys.MapString: studentLocation.mapString,
            UdacityClient.StudentLocationKeys.MediaURL: studentLocation.mediaURL,
            UdacityClient.StudentLocationKeys.Latitude: studentLocation.latitude,
            UdacityClient.StudentLocationKeys.Longitude: studentLocation.longitude
        ]
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









