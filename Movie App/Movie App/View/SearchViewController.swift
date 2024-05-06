//
//  SearchViewController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 05.04.2024.
//

import UIKit

class SearchResultsViewController: UITableViewController {
    
    var searchResults: [SearchShowModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell nib
        self.tableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
    }
    
    // MARK: - TableView number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    // MARK: - TableView cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultTableViewCell
        cell.textLabel?.text = searchResults[indexPath.row].show.name ?? ""
        return cell
    }
    
    // MARK: - TableView select item
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedResult = searchResults[indexPath.row]
        // Instantiate and present detail view controller
        let detailViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.detailShowModel = selectedResult.show
        present(detailViewController, animated: true, completion: nil)
    }
}

class SearchViewController: UIViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: SearchResultsViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set controller title
        title = "Search"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    // MARK: - Update Search Results
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        if let searchResultsController = searchController.searchResultsController as? SearchResultsViewController {
            DataController.sharedInstance.getSearch(searchString: text) { SearchedShows in
                searchResultsController.searchResults = SearchedShows
                // Reload table view data on the main thread
                DispatchQueue.main.async {
                    searchResultsController.tableView.reloadData()
                }
            } onFailure: {
                // Alert when there is no internet connection
                self.generateAlert(titleString: NSLocalizedString("generalTitleErrorNetwork", comment: ""), messageString: NSLocalizedString("generalMessageErrorNetwork", comment: ""))
            } onErrorAuth: {
                // Alert when access is denied
                self.generateAlert(titleString: NSLocalizedString("generalTitleAccessDenied", comment: ""), messageString: NSLocalizedString("generalMessageAccessDenied", comment: ""))
            } onErrorJSON: {
                // Alert when there is a problem with decoding the JSON
                self.generateAlert(titleString: NSLocalizedString("generalTitleErrorJSON", comment: ""), messageString: NSLocalizedString("generalMessageErrorJSON", comment: ""))
            }
        }
    }
    
    // MARK: - Generate Alert
    
    func generateAlert(titleString: String, messageString: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("buttonQuit", comment: ""), style: .default, handler: { (action:UIAlertAction!) -> Void in
                exit(0)
            }))
            self.present(alertController, animated: true)
        }
    }
}
