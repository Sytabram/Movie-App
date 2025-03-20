//
//  SearchViewController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 05.04.2024.
//

import UIKit

import UIKit

class SearchResultsViewController: UITableViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<Int, ItemShowModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, ItemShowModel>
    
    private lazy var dataSource: DataSource = {
        return DataSource(tableView: tableView) { tableView, indexPath, searchShowModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultTableViewCell
            cell.textLabel?.text = searchShowModel.name
            return cell
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        tableView.dataSource = dataSource
    }
    
    // MARK: - Updating Results
    func updateResults(with results: [SearchShowModel]) {
        let items = results.map { ItemShowModel(from: $0.show) }
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - TableView select item
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedResult = dataSource.itemIdentifier(for: indexPath) else { return }
        let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.detailShowModel = selectedResult
        present(detailViewController, animated: true, completion: nil)
    }
}

class SearchViewController: UIViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: SearchResultsViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    // MARK: - Update Search Results
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty, let searchResultsController = searchController.searchResultsController as? SearchResultsViewController else { return }
        Task {
            do {
                let searchedShows = try await DataController.sharedInstance.getSearch(searchString: text)
                DispatchQueue.main.async {
                    searchResultsController.updateResults(with: searchedShows)
                }
            } catch APIError.networkError {
                self.generateAlert(titleString: NSLocalizedString("generalTitleErrorNetwork", comment: ""), messageString: NSLocalizedString("generalMessageErrorNetwork", comment: ""))
            } catch APIError.unauthorized {
                self.generateAlert(titleString: NSLocalizedString("generalTitleAccessDenied", comment: ""), messageString: NSLocalizedString("generalMessageAccessDenied", comment: ""))
            } catch DataError.decodingError {
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
