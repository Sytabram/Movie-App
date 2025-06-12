//
//  SearchViewController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 05.04.2024.
//

import UIKit

// MARK: - SearchResultsViewController

class SearchResultsViewController: UITableViewController {
    
    // MARK: - Type Aliases
    
    typealias DataSource = UITableViewDiffableDataSource<Int, ShowItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, ShowItem>
    
    // MARK: - Properties
    
    private lazy var dataSource: DataSource = {
        return DataSource(tableView: tableView) { tableView, indexPath, showItem in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultTableViewCell
            cell.textLabel?.text = showItem.name
            return cell
        }
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        tableView.dataSource = dataSource
    }
    
    // MARK: - Public Methods
    
    func updateResults(with searchResults: [ShowSearchResult]) {
        let items = searchResults.map { ShowItem(from: $0.show) }
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let selectedResult = dataSource.itemIdentifier(for: indexPath) else { return }
        presentDetailViewController(for: selectedResult)
    }
    
    // MARK: - Private Methods
    
    private func presentDetailViewController(for showItem: ShowItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        detailViewController.showItem = showItem
        present(detailViewController, animated: true)
    }
}

// MARK: - SearchViewController

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    private let searchController = UISearchController(searchResultsController: SearchResultsViewController())
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupSearchController()
    }
    
    // MARK: - Setup
    
    private func setupViewController() {
        title = NSLocalizedString("titleSearch", comment: "")
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    // MARK: - Private Methods
    
    private func performSearch(with text: String, searchResultsController: SearchResultsViewController) {
        Task {
            do {
                let searchResults = try await DataController.shared.getSearch(searchString: text)
                await MainActor.run {
                    searchResultsController.updateResults(with: searchResults)
                }
            } catch {
                await MainActor.run {
                    ErrorManager.shared.handleError(error, in: self) { [weak self] in
                        guard let self = self else { return }
                        self.performSearch(with: text, searchResultsController: searchResultsController)
                    }
                }
            }
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text,
              !text.isEmpty,
              let searchResultsController = searchController.searchResultsController as? SearchResultsViewController else {
            return
        }
        
        performSearch(with: text, searchResultsController: searchResultsController)
    }
}
