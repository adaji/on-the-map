//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/18/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation

// MARK: - UdacityClient: NSObject

// Note: The structures of Udacity and Parse's HTTP methods are very different.
// It makes sense to have different methods for the two clients.
// I did move all the Parse-related properties and methods to a separate class
// to make the code cleaner here.

class UdacityClient: NSObject {
    
    // MARK: Properties
    
    var session: NSURLSession
    
    var sessionID: String? = nil
    var userID: String? = nil
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: Tasks for HTTP Methods
    
    func startTaskForGETMethod(method: String?, parameters: [String: AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSURLRequest(URL: NSURL(string: getUrlString(method, parameters: parameters))!)
        
        startTaskForHTTPMethod(request, completionHandler: completionHandler)
    }
    
    func startTaskForPOSTMethod(method: String?, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: getUrlString(method, parameters: nil))!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        startTaskForHTTPMethod(request, completionHandler: completionHandler)
    }
    
    func startTaskForDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: getUrlString(method, parameters: nil))!)
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        startTaskForHTTPMethod(request, completionHandler: completionHandler)
    }
    
    func startTaskForHTTPMethod(request: NSURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                print("There was an error with your request: \(error)")
                return
            }
            
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "No data received."]
                completionHandler(result: nil, error: NSError(domain: "startTaskForHTTPMethod", code: 1, userInfo: userInfo))
                return
            }
            
            // Subset data if it's Udacity method
            NetworkingDataHandler.parseJSONWithCompletionHandler(UdacityClient.subsetData(data), completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    // MARK: Helper Functions
    
    // Get url string
    func getUrlString(method: String?, parameters: [String: AnyObject]?) -> String {
        var urlString = UdacityClient.Constants.BaseURL
        if let method = method {
            urlString += method
        }
        if let parameters = parameters {
            urlString += NetworkingDataHandler.escapedParameters(parameters)
        }
        
        return urlString
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



