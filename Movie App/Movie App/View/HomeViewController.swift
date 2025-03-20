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
        title = "Home"
        homeCollectionView.register(UINib(nibName: "PosterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PosterCollectionViewCell")
        homeCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        homeCollectionView.collectionViewLayout = createLayout()
        configureDataSource(for: homeCollectionView)
        
        Task {
            do {
                self.applySnapshot(with: try await DataController.sharedInstance.getCategoryShows())
            } catch APIError.networkError {
                // Alert when internet connection is lost
                self.generateAlert(titleString: NSLocalizedString("generalTitleErrorNetwork", comment: ""), messageString: NSLocalizedString("generalMessageErrorNetwork", comment: ""))
                
            } catch APIError.unauthorized {
                // Alert when access is denied
                self.generateAlert(titleString: NSLocalizedString("generalTitleAccessDenied", comment: ""), messageString: NSLocalizedString("generalMessageAccessDenied", comment: ""))
                
            } catch DataError.decodingError {
                // Alert when there is a JSON decoding problem
                self.generateAlert(titleString: NSLocalizedString("generalTitleErrorJSON", comment: ""), messageString: NSLocalizedString("generalMessageErrorJSON", comment: ""))
                
            } catch APIError.notFound {
                self.generateAlert(titleString: NSLocalizedString("generalTitleErrorNotFound", comment: ""), messageString: NSLocalizedString("generalMessageErrorNotFound", comment: ""))
            }
            catch {
                // Manage any other unknown errors
                self.generateAlert(titleString: NSLocalizedString("generalTitleErrorGlobal", comment: ""), messageString: NSLocalizedString("generalMessageErrorGlobal", comment: ""))
            }
        }
    }
    // MARK: - Generate Alert
    func generateAlert(titleString:String, messageString:String){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("buttonQuit", comment: ""), style: .default, handler: { (action:UIAlertAction!) -> Void in
                exit(0);
            }))
            self.present(alertController, animated: true)
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemShowModel>()
        
        for (categoryName, shows) in data {
            let section = Section.category(categoryName)
            snapshot.appendSections([section])
            
            let items = shows.map { ItemShowModel(from: $0) }
            snapshot.appendItems(items, toSection: section)
        }
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
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
