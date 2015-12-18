//
//  SearchViewController.swift
//  OnTheMap
//
//  Created by Ada Ji on 12/17/15.
//  Copyright © 2015 Superada. All rights reserved.
//

import UIKit
import CoreData

// MARK: - SearchViewController: UIViewController

class SearchViewController: UIViewController {
    
    // MARK: Properties

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var studentInformationArray = [StudentInformation]()
    // The most recent data download task. We keep a reference to it so that it can
    // be canceled every time the search text changes
    var searchTask: NSURLSessionDataTask?
    // This view controller may temporarily download quite a few student information while the user
    // is typing in text. We don't want to add all of those data to the main context. So we will
    // put them in this temporary context instead.
    lazy var temporaryContext: NSManagedObjectContext = {
        var temporaryContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        return temporaryContext
    }()
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardDismissRecognizer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardDismissRecognizer()
    }
    
    // MARK: Actions
    
    @IBAction func cancel(sender: UIButton) {
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    // MARK: Show/Hide Keyboard
    
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    

}

// MARK: SearchViewController: UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    // Each time the search text changes we want to cancel any current download and start a new one
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Cancel the last task
        if let task = searchTask {
            task.cancel()
        }
        
        // TODO: Start a new download
        // Need search API
        searchTask = ParseClient.sharedInstance().searchForStudentInformationData { (success, studentInformationDictionaries, errorString) -> Void in
            
            if let errorString = errorString {
                print("Unable to fetch search results: \(errorString)")
                return
            }
            
            if let studentInformationDictionaries = studentInformationDictionaries {
                self.searchTask = nil
                
                // Create an array of StudentInformation instances in the temporary context
                self.temporaryContext.performBlock {
                    self.studentInformationArray = studentInformationDictionaries.map() {
                        StudentInformation(dictionary: $0, context: self.temporaryContext)
                    }
                    
                    // Reload the table on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView!.reloadData()
                    }
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

// MARK: SearchViewController: UIViewController

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentInformationArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId = "SearchResultCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseId)!
        
        let studentInformation = studentInformationArray[indexPath.row]
        cell.textLabel!.text = studentInformation.fullName()
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}














