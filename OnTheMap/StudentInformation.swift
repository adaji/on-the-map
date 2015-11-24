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
    
    var objectId = "" // StudentLocation object id on Parse
    var uniqueKey = "" // Udacity account (user) id
    var firstName = ""
    var lastName = ""
    var mapString = ""
    var mediaURL = ""
    var latitude = 0.0
    var longitude = 0.0
    var createdAt = NSDate()
    var updatedAt = NSDate()
    
    // MARK: Initializers
    
    init(dictionary: [String: AnyObject]) {
        if let objectId = dictionary[ParseClient.StudentInformationKeys.ObjectId] as? String {
            self.objectId = objectId
        }
        if let uniqueKey = dictionary[ParseClient.StudentInformationKeys.UniqueKey] as? String {
            self.uniqueKey = uniqueKey
        }
        if let firstName = dictionary[ParseClient.StudentInformationKeys.FirstName] as? String {
            self.firstName = firstName
        }
        if let lastName = dictionary[ParseClient.StudentInformationKeys.LastName] as? String {
            self.lastName = lastName
        }
        if let mapString = dictionary[ParseClient.StudentInformationKeys.MapString] as? String {
            self.mapString = mapString
        }
        if let mediaURL = dictionary[ParseClient.StudentInformationKeys.MediaURL] as? String {
            self.mediaURL = mediaURL
        }
        if let latitude = dictionary[ParseClient.StudentInformationKeys.Latitude] as? Double {
            self.latitude = latitude
        }
        if let longitude = dictionary[ParseClient.StudentInformationKeys.Longitude] as? Double {
            self.longitude = longitude
        }
        
        // Parse date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let createdAtString = dictionary[ParseClient.StudentInformationKeys.CreatedAt] as? String {
            createdAt = dateFormatter.dateFromString(createdAtString)!
        }
        if let updatedAtString = dictionary[ParseClient.StudentInformationKeys.UpdatedAt] as? String {
            updatedAt = dateFormatter.dateFromString(updatedAtString)!
        }
    }
    
    // Given an array of dictionaries, convert them to an array of StudentInformation objects
    static func allStudentInformationFromResults(results: [[String: AnyObject]]) -> [StudentInformation] {
        var allStudentInformation = [StudentInformation]()
        
        for result in results {
            allStudentInformation.append(StudentInformation(dictionary: result))
        }
        
        return allStudentInformation
    }
    
    // MARK: Convenient Methods
    
    // Return the dictionary version of StudentInformation (for posting/updating student information, etc.)
    func dictionary() -> [String: AnyObject] {
        return [
            ParseClient.StudentInformationKeys.UniqueKey: uniqueKey,
            ParseClient.StudentInformationKeys.FirstName: firstName,
            ParseClient.StudentInformationKeys.LastName: lastName,
            ParseClient.StudentInformationKeys.MapString: mapString,
            ParseClient.StudentInformationKeys.MediaURL: mediaURL,
            ParseClient.StudentInformationKeys.Latitude: latitude,
            ParseClient.StudentInformationKeys.Longitude: longitude
        ]
    }
    
    // Return student's full name
    func fullName() -> String {
        return "\(firstName) \(lastName)"
    }
    
    // Return student's initials
    func initials() -> String {
        let first = firstName.substringToIndex(firstName.startIndex.advancedBy(1))
        let last = lastName.substringToIndex(lastName.startIndex.advancedBy(1))
        return "\(first) \(last)"
    }
    
}









