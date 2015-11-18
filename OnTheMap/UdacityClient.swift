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
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: POST
    
    func startTaskForPOSTMethod(method: String, httpBody: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        startTaskForPOSTMethod(method, parameters: [String: AnyObject](), httpBody: httpBody, completionHandler: completionHandler)
    }
    
    func startTaskForPOSTMethod(method: String, parameters: [String: AnyObject], httpBody: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let urlString = Constants.BaseURL + method
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
            
            UdacityClient.parseJSONWithCompletionHandler(UdacityClient.subsetData(data), completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    func startTaskForDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let urlString = Constants.BaseURL + method
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
            
            UdacityClient.parseJSONWithCompletionHandler(UdacityClient.subsetData(data), completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    // MARK: GET
    
    func startTaskForGETMethod(method: String, parameters: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.BaseURL)!)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard error == nil else {
                print("There was an error with your request: \(error)")
                return
            }
            
            guard let data = data else {
                return
            }
            
            print(UdacityClient.subsetData(data))
        }
        
        task.resume()
    }
    
    // MARK: Helper Functions
    
    // Substitute values in HTTP body
    class func substitutedHTTPBody(httpBody: String, parameters: [String: String]) -> String {
        var result = httpBody
        for key in parameters.keys {
            if result.rangeOfString("<\(key)>") != nil {
                result = result.stringByReplacingOccurrencesOfString("<\(key)>", withString: parameters[key]!)
            }
        }
        
        return result
    }
    
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    // Subset response data
    class func subsetData(data: NSData) -> NSData {
        return data.subdataWithRange(NSMakeRange(5, data.length - 5))
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}



