//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/18/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation
import CoreData

// MARK: - StudentInformation: NSManagedObject

class StudentInformation: NSManagedObject {
    
    // MARK: Keys
    
    struct Keys {
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaUrl = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
    }
    
    // MARK: Properties
    
    @NSManaged var objectId: String // StudentLocation object id on Parse
    @NSManaged var uniqueKey: String // Udacity account (user) id
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var mapString: String
    @NSManaged var mediaUrl: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate
    
    // MARK: Initializers
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("StudentInformation", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
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
        if let mediaUrl = dictionary[Keys.MediaUrl] as? String {
            self.mediaUrl = mediaUrl
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
            allStudentInformation.append(StudentInformation(dictionary: result, context: CoreDataStackManager.sharedInstance().managedObjectContext))
        }
        CoreDataStackManager.sharedInstance().saveContext()
        
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
            Keys.MediaUrl: mediaUrl,
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









