//
//  HomeViewController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 26.03.2024.
//

import UIKit

class HomeViewController: UIViewController{
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    enum Section: Hashable {
        case category(String)
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemShowModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("titleHome", comment: "")
        homeCollectionView.register(UINib(nibName: "PosterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PosterCollectionViewCell")
        homeCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        homeCollectionView.collectionViewLayout = createLayout()
        configureDataSource(for: homeCollectionView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            fetchData()
    }
    
    // MARK: - Fetch Data
    private func fetchData() {
        Task {
            do {
                let categoryShows = try await DataController.sharedInstance.getCategoryShows()
                self.applySnapshot(with: categoryShows)
            } catch {
                ErrorManager.shared.handleError(error, in: self, retryAction: { [weak self] in
                    self?.fetchData()
                })
            }
        }
    }
    
    // MARK: - Create Layout
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            // Header Configuration
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(10))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            headerItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            
            // Item Configuration
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
            
            // Group Configuration
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.40), heightDimension: .estimated(250))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // Section Configuration
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.boundarySupplementaryItems = [headerItem] // Attach header to the section
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
            
            return section
        }
    }
    // MARK: - Configure DataSource
    func configureDataSource(for collectionView: UICollectionView) {
        dataSource = UICollectionViewDiffableDataSource<Section, ItemShowModel>(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCollectionViewCell", for: indexPath) as! PosterCollectionViewCell
            cell.configureCell(item)
            return cell
        }
        homeCollectionView.delegate = self
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                fatalError("Unexpected additional view type")
            }
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as? SectionHeaderView else {
                fatalError("Unable to scroll a HeaderView with the specified identifier")
            }
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch section {
            case .category(let title):
                header.label.text = title
            }
            return header
        }
    }
    // MARK: - Apply Snapshot
    func applySnapshot(with data: [(String, [ShowModel])]) {
        // Creating a new snapshot
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, ItemShowModel>()
        
        for (categoryName, shows) in data {
            let section = Section.category(categoryName)
            newSnapshot.appendSections([section])
            
            let items = shows.map { ItemShowModel(from: $0) }
            newSnapshot.appendItems(items, toSection: section)
        }
        
        // Compare whether the data is identical to the current state
        let currentSnapshot = dataSource.snapshot()
        let areSnapshotsIdentical = currentSnapshot.sectionIdentifiers == newSnapshot.sectionIdentifiers &&
                                   currentSnapshot.itemIdentifiers == newSnapshot.itemIdentifiers
        
        // If the data is identical, avoid unnecessary updating
        guard !areSnapshotsIdentical else { return }
        
        // Apply with controlled animation
        DispatchQueue.main.async {
            let animationOptions: UIView.AnimationOptions = [.transitionCrossDissolve, .allowUserInteraction]
            
            UIView.transition(with: self.homeCollectionView, duration: 0.3, options: animationOptions) {
                self.dataSource.apply(newSnapshot, animatingDifferences: false)
            }
        }
    }
}
// MARK: - Extension : Did Select Item
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let selectedShowModel = dataSource.itemIdentifier(for: indexPath) else { return }

        let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController

        detailViewController.detailShowModel = selectedShowModel

        if let navController = self.navigationController {
            navController.pushViewController(detailViewController, animated: true)
        }
    }
}
