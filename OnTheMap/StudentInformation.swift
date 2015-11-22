//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/18/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation

// MARK: - StudentInformation

struct StudentInformation {
    
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
        if let objectId = dictionary[UdacityClient.StudentInformationKeys.ObjectId] as? String {
            self.objectId = objectId
        }
        if let uniqueKey = dictionary[UdacityClient.StudentInformationKeys.UniqueKey] as? String {
            self.uniqueKey = uniqueKey
        }
        if let firstName = dictionary[UdacityClient.StudentInformationKeys.FirstName] as? String {
            self.firstName = firstName
        }
        if let lastName = dictionary[UdacityClient.StudentInformationKeys.LastName] as? String {
            self.lastName = lastName
        }
        fullName = "\(firstName) \(lastName)"
        if let mapString = dictionary[UdacityClient.StudentInformationKeys.MapString] as? String {
            self.mapString = mapString
        }
        if let mediaURL = dictionary[UdacityClient.StudentInformationKeys.MediaURL] as? String {
            self.mediaURL = mediaURL
        }
        if let latitude = dictionary[UdacityClient.StudentInformationKeys.Latitude] as? Double {
            self.latitude = latitude
        }
        if let longitude = dictionary[UdacityClient.StudentInformationKeys.Longitude] as? Double {
            self.longitude = longitude
        }
        
        // Parse date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let createdAtString = dictionary[UdacityClient.StudentInformationKeys.CreatedAt] as? String {
            createdAt = dateFormatter.dateFromString(createdAtString)!
        }
        if let updatedAtString = dictionary[UdacityClient.StudentInformationKeys.UpdatedAt] as? String {
            updatedAt = dateFormatter.dateFromString(updatedAtString)!
        }
    }
    
    // Given an array of dictionaries, convert them to an array of StudentInformation objects
    static func allStudentInformationFromResults(results: [[String: AnyObject]]) -> [StudentInformation] {
        var locations = [StudentInformation]()
        
        for result in results {
            locations.append(StudentInformation(dictionary: result))
        }
        
        return locations
    }
    
    // Convert StudentInformation object to dictionary (for posting/updating student information)
    static func dictionaryFromStudentInformation(studentInformation: StudentInformation) -> [String: AnyObject] {
        return [
            UdacityClient.StudentInformationKeys.UniqueKey: studentInformation.uniqueKey,
            UdacityClient.StudentInformationKeys.FirstName: studentInformation.firstName,
            UdacityClient.StudentInformationKeys.LastName: studentInformation.lastName,
            UdacityClient.StudentInformationKeys.MapString: studentInformation.mapString,
            UdacityClient.StudentInformationKeys.MediaURL: studentInformation.mediaURL,
            UdacityClient.StudentInformationKeys.Latitude: studentInformation.latitude,
            UdacityClient.StudentInformationKeys.Longitude: studentInformation.longitude
        ]
    }
    
}









