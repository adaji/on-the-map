//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/18/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation

// MARK: - UdacityClient: NSObject

class UdacityClient: NSObject {
    
    // MARK: Properties
    
    var session: NSURLSession
    
    var sessionID: String? = nil
    var userID: String? = nil
    
    var allStudentInformation: [StudentInformation]? = nil // Save/update student information data locally every time it's queried
    var myStudentInformation: StudentInformation? = nil // Save/update user's student information locally every time it's queried, posted or updated
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: Tasks for Udacity HTTP Methods
    
    func startTaskForUdacityPOSTMethod(method: String, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let urlString = Constants.UdacityBaseURL + method
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = HTTPMethods.POST
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        startTaskForUdacityHTTPMethod(request, completionHandler: completionHandler)
    }
    
    func startTaskForUdacityDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let urlString = Constants.UdacityBaseURL + method
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = HTTPMethods.DELETE
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        startTaskForUdacityHTTPMethod(request, completionHandler: completionHandler)
    }
    
    func startTaskForUdacityGETMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let urlString = Constants.UdacityBaseURL + method
        let request = NSURLRequest(URL: NSURL(string: urlString)!)
        
        startTaskForUdacityHTTPMethod(request, completionHandler: completionHandler)
    }
    
    func startTaskForUdacityHTTPMethod(request: NSURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                print("There was an error with your request: \(error)")
                return
            }
            
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "No data received."]
                completionHandler(result: nil, error: NSError(domain: "startTaskForUdacityHTTPMethod", code: 1, userInfo: userInfo))
                return
            }
            
            NetworkingDataHandler.parseJSONWithCompletionHandler(UdacityClient.subsetData(data), completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    // MARK: Tasks for Parse HTTP Methods
    
    func startTaskForParseGETMethod(optionalParameters: [String: AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var urlString = Constants.ParseBaseURL
        if let parameters = optionalParameters {
            urlString += NetworkingDataHandler.escapedParameters(parameters)
        }
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderKeys.ParseAppIdKey)
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: HTTPHeaderKeys.ParseAPIKey)
        
        startTaskForParseHTTPMethod(request, completionHandler: completionHandler)
    }
    
    func startTaskForParsePOSTMethod(jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let urlString = Constants.ParseBaseURL
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = HTTPMethods.POST
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderKeys.ParseAppIdKey)
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: HTTPHeaderKeys.ParseAPIKey)
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        startTaskForParseHTTPMethod(request, completionHandler: completionHandler)
    }
    
    func startTaskForParsePUTMethod(method: String, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let urlString = Constants.ParseBaseURL + method
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = HTTPMethods.PUT
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderKeys.ParseAppIdKey)
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: HTTPHeaderKeys.ParseAPIKey)
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        startTaskForParseHTTPMethod(request, completionHandler: completionHandler)
    }
    
    func startTaskForParseHTTPMethod(request: NSURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                print("There was an error with your request: \(error)")
                return
            }
            
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "No data received."]
                completionHandler(result: nil, error: NSError(domain: "startTaskForParseHTTPMethod", code: 1, userInfo: userInfo))
                return
            }

            NetworkingDataHandler.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    // MARK: Helper Functions
    
    // Substitute the key for the value that is contained within the method name
    class func substituteKeyInMethod(method: String, key: String, value: String) -> String {
        if method.rangeOfString("<\(key)>") != nil {
            return method.stringByReplacingOccurrencesOfString("<\(key)>", withString: value)
        } else {
            return method
        }
    }
    
    // Subset response data from Udacity
    class func subsetData(data: NSData) -> NSData {
        return data.subdataWithRange(NSMakeRange(5, data.length - 5))
    }
        
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
}



