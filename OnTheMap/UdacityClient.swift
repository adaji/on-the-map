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
    var userID: Int? = nil
    
    var studentLocations: [StudentLocation]? = nil
    var udacityUser: UdacityUser? = nil
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: Udacity HTTP Methods
    
    // POST
    func startTaskForUdacityPOSTMethod(method: String, httpBody: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        startTaskForUdacityPOSTMethod(method, parameters: [String: AnyObject](), httpBody: httpBody, completionHandler: completionHandler)
    }
    
    // POST
    func startTaskForUdacityPOSTMethod(method: String, parameters: [String: AnyObject], httpBody: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let urlString = Constants.UdacityBaseURL + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = HTTPMethods.POST
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard error == nil else {
                print("There was an error with your request: \(error)")
                return
            }
            
            guard let data = data else {
                return
            }
            
            NetworkingDataHandler.parseJSONWithCompletionHandler(UdacityClient.subsetData(data), completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    // DELETE
    func startTaskForUdacityDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let urlString = Constants.UdacityBaseURL + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = HTTPMethods.DELETE
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard error == nil else {
                print("There was an error with your request: \(error)")
                return
            }
            
            guard let data = data else {
                return
            }
            
            NetworkingDataHandler.parseJSONWithCompletionHandler(UdacityClient.subsetData(data), completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    func startTaskForUdacityGETMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let urlString = Constants.UdacityBaseURL + method
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            guard error == nil else {
                print("There was an error with your request: \(error)")
                return
            }
            
            guard let data = data else {
                return
            }
            
            NetworkingDataHandler.parseJSONWithCompletionHandler(UdacityClient.subsetData(data), completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    // MARK: Parse HTTP Methods
    
    // GET
    func startTaskForParseGETMethod(parameters: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {

        let urlString = Constants.ParseBaseURL + NetworkingDataHandler.escapedParameters(parameters)
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderKeys.ParseAppIdKey)
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: HTTPHeaderKeys.ParseAPIKey)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard error == nil else {
                print("There was an error with your request: \(error)")
                return
            }
            
            guard let data = data else {
                return
            }
            
            NetworkingDataHandler.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    // POST
    func startTaskForParsePOSTMethod(httpBody: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let urlString = Constants.ParseBaseURL
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = HTTPMethods.POST
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderKeys.ParseAppIdKey)
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: HTTPHeaderKeys.ParseAPIKey)
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard error == nil else {
                print("There was an error with your request: \(error)")
                return
            }
            
            guard let data = data else {
                return
            }
            
            NetworkingDataHandler.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    // TODO: PUT
    
    
    // MARK: Helper Functions
    
    // Substitute keys and values in JSON body
    class func jsonBodyWithParameters(parameters: [String: AnyObject]) -> String {
        var jsonBody = "{"
        for (key, value) in parameters {
            jsonBody += "\"\(key)\": \"\(value)\", "
        }
        
        let end = jsonBody.endIndex.advancedBy(-2)
        return jsonBody.substringToIndex(end) + "}"
    }
    
    // Substitute values in HTTP body
    class func substituteKeysInHTTPBody(httpBody: String, parameters: [String: String]) -> String {
        var result = httpBody
        for key in parameters.keys {
            if result.rangeOfString("<\(key)>") != nil {
                result = result.stringByReplacingOccurrencesOfString("<\(key)>", withString: parameters[key]!)
            }
        }
        
        return result
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func substituteKeyInMethod(method: String, key: String, value: String) -> String {
        if method.rangeOfString("<\(key)>") != nil {
            return method.stringByReplacingOccurrencesOfString("<\(key)>", withString: value)
        }
        else {
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



