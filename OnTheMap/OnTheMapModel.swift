//
//  OnTheMapModel.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/24/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation

// MARK: - OnTheMapModel: NSObject
// Store student information data

class OnTheMapModel: NSObject {

    // Save/update student information data every time it's queried
    var allStudentInformation: [StudentInformation]? = nil
    // Save/update user's student information every time it's queried, posted or updated
    var myStudentInformation: StudentInformation? = nil

}
