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
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: Tasks for HTTP Methods
    
    func startTaskForPOSTMethod(client: Client, method: String?, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: getUrlString(client, method: method, parameters: nil))!)
        request.HTTPMethod = HTTPMethods.POST
        switch client {
        case .Udacity:
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            break
        case .Parse:
            request.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderKeys.ParseAppIdKey)
            request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: HTTPHeaderKeys.ParseAPIKey)
            break
        }
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        startTaskForHTTPMethod(client, request: request, completionHandler: completionHandler)
    }
    
    func startTaskForGETMethod(client: Client, method: String?, parameters: [String: AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: getUrlString(client, method: method, parameters: parameters))!)
        if client == .Parse {
            request.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderKeys.ParseAppIdKey)
            request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: HTTPHeaderKeys.ParseAPIKey)
        }
        
        startTaskForHTTPMethod(client, request: request, completionHandler: completionHandler)
    }
    
    func startTaskForDELETEMethod(client: Client, method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: getUrlString(client, method: method, parameters: nil))!)
        request.HTTPMethod = HTTPMethods.DELETE
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        startTaskForHTTPMethod(client, request: request, completionHandler: completionHandler)
    }
    
    func startTaskForPUTMethod(client: Client, method: String, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: getUrlString(client, method: method, parameters: nil))!)
        request.HTTPMethod = HTTPMethods.PUT
        if client == .Parse {
            request.addValue(Constants.ParseAppID, forHTTPHeaderField: HTTPHeaderKeys.ParseAppIdKey)
            request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: HTTPHeaderKeys.ParseAPIKey)
        }
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        startTaskForHTTPMethod(client, request: request, completionHandler: completionHandler)
    }
    
    func startTaskForHTTPMethod(client: Client, request: NSURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
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
            if client == .Udacity {
                NetworkingDataHandler.parseJSONWithCompletionHandler(UdacityClient.subsetData(data), completionHandler: completionHandler)
            } else {
                NetworkingDataHandler.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        task.resume()
    }
    
    // MARK: Helper Functions
    
    // Get url string
    func getUrlString(client: Client, method: String?, parameters: [String: AnyObject]?) -> String {
        var urlString = ""
        switch client {
        case .Udacity:
            urlString = Constants.UdacityBaseURL
            break
        case .Parse:
            urlString = Constants.ParseBaseURL
            break
        }
        if let method = method {
            urlString += method
        }
        if let parameters = parameters {
            urlString += NetworkingDataHandler.escapedParameters(parameters)
        }
        
        return urlString
    }
    
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



