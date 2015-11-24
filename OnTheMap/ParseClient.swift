//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/24/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation

// MARK: - ParseClient: NSObject

class ParseClient: NSObject {
    
    // MARK: Properties
    
    var session: NSURLSession
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: Tasks for HTTP Methods
    
    func startTaskForGETMethod(method: String?, parameters: [String: AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: getUrlString(method, parameters: parameters))!)
        request.addValue(ParseClient.Constants.AppID, forHTTPHeaderField: ParseClient.HTTPHeaderKeys.ParseAppIdKey)
        request.addValue(ParseClient.Constants.APIKey, forHTTPHeaderField: ParseClient.HTTPHeaderKeys.ParseAPIKey)
        
        startTaskForHTTPMethod(request, completionHandler: completionHandler)
    }
    
    func startTaskForPOSTMethod(jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: getUrlString(nil, parameters: nil))!)
        request.HTTPMethod = "POST"
        request.addValue(ParseClient.Constants.AppID, forHTTPHeaderField: ParseClient.HTTPHeaderKeys.ParseAppIdKey)
        request.addValue(ParseClient.Constants.APIKey, forHTTPHeaderField: ParseClient.HTTPHeaderKeys.ParseAPIKey)
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        startTaskForHTTPMethod(request, completionHandler: completionHandler)
    }
    
    func startTaskForPUTMethod(method: String, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: getUrlString(method, parameters: nil))!)
        request.HTTPMethod = "PUT"
        request.addValue(ParseClient.Constants.AppID, forHTTPHeaderField: ParseClient.HTTPHeaderKeys.ParseAppIdKey)
        request.addValue(ParseClient.Constants.APIKey, forHTTPHeaderField: ParseClient.HTTPHeaderKeys.ParseAPIKey)
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
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
            
            NetworkingDataHandler.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    // MARK: Helper Functions
    
    // Get url string
    func getUrlString(method: String?, parameters: [String: AnyObject]?) -> String {
        var urlString = ParseClient.Constants.BaseURL
        if let method = method {
            urlString += method
        }
        if let parameters = parameters {
            urlString += NetworkingDataHandler.escapedParameters(parameters)
        }
        
        return urlString
    }

    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
    
}
