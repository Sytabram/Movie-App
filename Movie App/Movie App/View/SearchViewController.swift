//
//  SearchViewController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 05.04.2024.
//

import UIKit

import UIKit

class SearchResultsViewController: UITableViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<Int, ShowItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, ShowItem>
    
    private lazy var dataSource: DataSource = {
        return DataSource(tableView: tableView) { tableView, indexPath, ShowSearchResult in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultTableViewCell
            cell.textLabel?.text = ShowSearchResult.name
            return cell
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        tableView.dataSource = dataSource
    }
    
    // MARK: - Updating Results
    func updateResults(with results: [ShowSearchResult]) {
        let items = results.map { ShowItem(from: $0.show) }
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
        title = NSLocalizedString("titleSearch", comment: "")
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    // MARK: - Update Search Results
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty,
              let searchResultsController = searchController.searchResultsController as? SearchResultsViewController else { return }
        
        performSearch(with: text, searchResultsController: searchResultsController)
    }
    
    private func performSearch(with text: String, searchResultsController: SearchResultsViewController) {
        Task {
            do {
                let searchedShows = try await DataController.sharedInstance.getSearch(searchString: text)
                DispatchQueue.main.async {
                    searchResultsController.updateResults(with: searchedShows)
                }
            } catch let error {
                ErrorManager.shared.handleError(error, in: self) { [weak self] in
                    guard let self = self else { return }
                    self.performSearch(with: text, searchResultsController: searchResultsController)
                }
            }
        }
    }
}
