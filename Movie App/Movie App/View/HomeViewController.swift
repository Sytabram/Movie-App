//
//  HomeViewController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 26.03.2024.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    let homeScrollView = UIScrollView()

    let verticalStackView: UIStackView = {
         let stackView = UIStackView()
         stackView.axis = .vertical
         stackView.alignment = .fill
         stackView.spacing = 5
         return stackView
     }()
    
    var categoriesCountDict: [Int: Int] = [:]
    var categoryShowsModel: [(String, [ShowModel])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Title of controller
        title = "Home"
        setupScrollView()
        Task {
            do {
                let homeCategoryShowsModel = try await DataController.sharedInstance.getCategoryShows()
                
                self.setupCategoryCollectionView(with: homeCategoryShowsModel)
                
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
    
    // MARK: - Setup ScrollView and StackView
    func setupScrollView() {
        // Make sure autoresizing mask constraints are disabled
        homeScrollView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(homeScrollView)
        let viewLayout = view.safeAreaLayoutGuide
        // Activate constraints for the scroll view
        NSLayoutConstraint.activate([
            homeScrollView.topAnchor.constraint(equalTo: viewLayout.topAnchor, constant: 0.0),
            homeScrollView.leadingAnchor.constraint(equalTo: viewLayout.leadingAnchor, constant: 0.0),
            homeScrollView.trailingAnchor.constraint(equalTo: viewLayout.trailingAnchor, constant: 0.0),
            homeScrollView.bottomAnchor.constraint(equalTo: viewLayout.bottomAnchor, constant: 0.0),
        ])
        
        homeScrollView.addSubview(verticalStackView)
        let scrollViewContentLayout = homeScrollView.contentLayoutGuide
        let scrollViewFrameLayout = homeScrollView.frameLayoutGuide
        // Activate constraints for the vertical stack view
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: scrollViewContentLayout.topAnchor, constant: 0),
            verticalStackView.leadingAnchor.constraint(equalTo: scrollViewContentLayout.leadingAnchor, constant: 0),
            verticalStackView.trailingAnchor.constraint(equalTo: scrollViewContentLayout.trailingAnchor, constant: 0),
            verticalStackView.bottomAnchor.constraint(equalTo: scrollViewContentLayout.bottomAnchor, constant: 0),
            verticalStackView.widthAnchor.constraint(equalTo: scrollViewFrameLayout.widthAnchor, constant: 0),
        ])
    }

    // MARK: - Setup Category CollectionView
    func setupCategoryCollectionView(with homeCategoryShowsModel: [(String, [ShowModel])]) {
        // Store the provided home category shows model
        categoryShowsModel = homeCategoryShowsModel
        
        for (index, (category, showsModels)) in homeCategoryShowsModel.enumerated() {
            // Create a UICollectionView for each category
            
            // Store the count of show models for each category
            categoriesCountDict[index] = showsModels.count
            
            // Create and add label to display the category name
            let homeCategoryLabel = UILabel()
            homeCategoryLabel.text = category
            homeCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
            verticalStackView.addArrangedSubview(homeCategoryLabel)
            homeCategoryLabel.sizeToFit()
            
            // Create the UICollectionView for the category
            let categoryCollectionView: UICollectionView = {
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .horizontal
                let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
                collectionView.backgroundColor = .clear
                collectionView.register(UINib(nibName: "PosterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "posterCell")
                collectionView.showsHorizontalScrollIndicator = false
                return collectionView
            }()
            categoryCollectionView.dataSource = self
            categoryCollectionView.delegate = self
            
            // Assign a tag to the collection view for identification
            categoryCollectionView.tag = index
            
            // Add the collection view to the vertical stack view
            verticalStackView.addArrangedSubview(categoryCollectionView)
            
            // Set the height constraint for the collection view
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        }
    }

    // MARK: - CollectionView number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // MARK: - CollectionView number of items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesCountDict[collectionView.tag] ?? 0
    }
    
    // MARK: - CollectionView cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "posterCell", for: indexPath) as! PosterCollectionViewCell
        cell.posterImageView.image = nil
            // Load image asynchronously
        if let imageURLString = self.categoryShowsModel[collectionView.tag].1[indexPath.row].image?.original {
            APIController.sharedInstance.loadImage(from: imageURLString) { image in
                    DispatchQueue.main.async {
                        // Update the cell image with the loaded image
                        cell.posterImageView.image = image
                    }
                }
            }
        cell.posterNameLabel.text = self.categoryShowsModel[collectionView.tag].1[indexPath.row].name
        return cell
    }
    
    // MARK: - CollectionView select item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedShowModel = self.categoryShowsModel[collectionView.tag].1[indexPath.row]
        let detailViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        // Transfer data to the new window
        detailViewController.detailShowModel = selectedShowModel
        
        // Present the new window
        if let tabBarController = self.tabBarController,
           let navController = tabBarController.viewControllers?.first as? UINavigationController {
            navController.pushViewController(detailViewController, animated: true)
        }
    }
    // MARK: - CollectionView size for item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.40, height: 250)
    }
}
