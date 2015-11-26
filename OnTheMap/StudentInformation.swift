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
    
    // MARK: Keys
    
    struct Keys {
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
        if let objectId = dictionary[Keys.ObjectId] as? String {
            self.objectId = objectId
        }
        if let uniqueKey = dictionary[Keys.UniqueKey] as? String {
            self.uniqueKey = uniqueKey
        }
        if let firstName = dictionary[Keys.FirstName] as? String {
            self.firstName = firstName
        }
        if let lastName = dictionary[Keys.LastName] as? String {
            self.lastName = lastName
        }
        if let mapString = dictionary[Keys.MapString] as? String {
            self.mapString = mapString
        }
        if let mediaURL = dictionary[Keys.MediaURL] as? String {
            self.mediaURL = mediaURL
        }
        if let latitude = dictionary[Keys.Latitude] as? Double {
            self.latitude = latitude
        }
        if let longitude = dictionary[Keys.Longitude] as? Double {
            self.longitude = longitude
        }
        
        // Parse date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let createdAtString = dictionary[Keys.CreatedAt] as? String {
            createdAt = dateFormatter.dateFromString(createdAtString)!
        }
        if let updatedAtString = dictionary[Keys.UpdatedAt] as? String {
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
            Keys.UniqueKey: uniqueKey,
            Keys.FirstName: firstName,
            Keys.LastName: lastName,
            Keys.MapString: mapString,
            Keys.MediaURL: mediaURL,
            Keys.Latitude: latitude,
            Keys.Longitude: longitude
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









