//
//  HomeViewController.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 26.03.2024.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let itemWidthFraction: CGFloat = 0.40
        static let estimatedHeight: CGFloat = 250
        static let headerPadding: CGFloat = 8
        static let itemPadding: CGFloat = 4
        static let sectionPadding: CGFloat = 8
        static let headerEstimatedHeight: CGFloat = 10
    }
    
    private enum AnimationConstants {
        static let transitionDuration: TimeInterval = 0.3
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    enum Section: Hashable {
        case category(String)
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, ShowItem>!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchData()
    }
    
    // MARK: - Setup
    
    private func setupViewController() {
        title = NSLocalizedString("titleHome", comment: "")
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "PosterCollectionViewCell", bundle: nil),
                               forCellWithReuseIdentifier: "PosterCollectionViewCell")
        collectionView.register(SectionHeaderView.self,
                               forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                               withReuseIdentifier: "SectionHeaderView")
        collectionView.collectionViewLayout = createLayout()
        configureDataSource()
    }
    
    // MARK: - Data Management
    
    private func fetchData() {
        Task {
            do {
                let categoryShows = try await DataController.shared.getCategoryShows()
                await MainActor.run {
                    self.applySnapshot(with: categoryShows)
                }
            } catch {
                await MainActor.run {
                    ErrorManager.shared.handleError(error, in: self) { [weak self] in
                        self?.fetchData()
                    }
                }
            }
        }
    }
    
    // MARK: - Layout Creation
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            return self.createSection()
        }
    }
    
    private func createSection() -> NSCollectionLayoutSection {
        // Header Configuration
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(LayoutConstants.headerEstimatedHeight)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        headerItem.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: LayoutConstants.headerPadding,
            bottom: 0,
            trailing: LayoutConstants.headerPadding
        )
        
        // Item Configuration
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: LayoutConstants.itemPadding,
            bottom: 0,
            trailing: LayoutConstants.itemPadding
        )
        
        // Group Configuration
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(LayoutConstants.itemWidthFraction),
            heightDimension: .estimated(LayoutConstants.estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section Configuration
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.boundarySupplementaryItems = [headerItem]
        section.contentInsets = NSDirectionalEdgeInsets(
            top: LayoutConstants.sectionPadding,
            leading: 0,
            bottom: LayoutConstants.sectionPadding,
            trailing: 0
        )
        
        return section
    }
    
    // MARK: - DataSource Configuration
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ShowItem>(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCollectionViewCell", for: indexPath) as! PosterCollectionViewCell
            cell.configure(with: item)
            return cell
        }
        
        collectionView.delegate = self
        configureSupplementaryViewProvider()
    }
    
    private func configureSupplementaryViewProvider() {
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                fatalError("Unexpected supplementary view type")
            }
            
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "SectionHeaderView",
                for: indexPath
            ) as? SectionHeaderView else {
                fatalError("Unable to dequeue SectionHeaderView")
            }
            
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch section {
            case .category(let title):
                header.label.text = title
            }
            return header
        }
    }
    
    // MARK: - Snapshot Management
    
    private func applySnapshot(with data: [(String, [Show])]) {
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, ShowItem>()
        
        for (categoryName, shows) in data {
            let section = Section.category(categoryName)
            newSnapshot.appendSections([section])
            
            let items = shows.map { ShowItem(from: $0) }
            newSnapshot.appendItems(items, toSection: section)
        }
        
        // Avoid unnecessary updates if data is identical
        let currentSnapshot = dataSource.snapshot()
        let areSnapshotsIdentical = currentSnapshot.sectionIdentifiers == newSnapshot.sectionIdentifiers &&
                                   currentSnapshot.itemIdentifiers == newSnapshot.itemIdentifiers
        
        guard !areSnapshotsIdentical else { return }
        
        applySnapshotWithAnimation(newSnapshot)
    }
    
    private func applySnapshotWithAnimation(_ snapshot: NSDiffableDataSourceSnapshot<Section, ShowItem>) {
        let animationOptions: UIView.AnimationOptions = [.transitionCrossDissolve, .allowUserInteraction]
        
        UIView.transition(
            with: collectionView,
            duration: AnimationConstants.transitionDuration,
            options: animationOptions
        ) {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedShowItem = dataSource.itemIdentifier(for: indexPath) else { return }
        presentDetailViewController(for: selectedShowItem)
    }
    
    // MARK: - Private Methods
    
    private func presentDetailViewController(for showItem: ShowItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        detailViewController.showItem = showItem
        
        if let navController = navigationController {
            navController.pushViewController(detailViewController, animated: true)
        }
    }
}
