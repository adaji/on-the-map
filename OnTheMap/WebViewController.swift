//
//  WebViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/23/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

// MARK: - WebViewController: UIViewController

class WebViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var webView: UIWebView!
    
    var progressView: UIProgressView? = nil
    var loadingCompleted: Bool = false
    var timer: NSTimer? = nil
    
    var urlRequest: NSURLRequest? = nil
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "On the Map"
        
        webView.scalesPageToFit = true
        
        progressView = UIProgressView(frame: CGRectMake(0, 0, view.frame.size.width, 10))
        progressView!.tintColor = UIColor.orangeColor()
        view.addSubview(progressView!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if urlRequest != nil {
            webView.loadRequest(urlRequest!)
        }
    }
    
    // MARK: Timer Callback
    
    func timerCallback() {
        if loadingCompleted {
            if progressView!.progress >= 1 {
                progressView!.hidden = true
                timer!.invalidate()
            } else {
                progressView!.progress += 0.1
            }
        } else {
            progressView!.progress += 0.05
            if progressView!.progress >= 0.95 {
                progressView!.progress = 0.95
            }
        }
    }

    // Show error
    func showAlert(message: String?) {
        let message = !message!.isEmpty ? message : "An unknown error has occurred."
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

// MARK: - WebViewController: UIWebViewDelegate

extension WebViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(webView: UIWebView) {
        progressView!.progress = 0.0
        // 0.01667 is roughly 1/60, so it will update at 60 FPS
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: "timerCallback", userInfo: nil, repeats: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loadingCompleted = true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if let error = error {
            showAlert(error.description)
        } else {
            showAlert("Loading failed.")
        }
    }
    
}















