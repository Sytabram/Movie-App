//
//  DetailViewController.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 05.04.2024.
//

import UIKit
import SafariServices

// MARK: - DetailViewController

class DetailViewController: UIViewController {
    
    // MARK: - Constants
    
    enum UIConstants {
        static let posterCornerRadius: CGFloat = 25
        static let namesFontSize: CGFloat = 24
        static let ratingFontSize: CGFloat = 18
        static let tableViewCornerRadius: CGFloat = 10
        static let tableViewBorderWidth: CGFloat = 1
        static let summaryMaxLength: Int = 150
    }
    
    enum AnimationConstants {
        static let toastDuration: TimeInterval = 1.5
        static let fadeAnimationDuration: TimeInterval = 0.3
        static let checkmarkAnimationDuration: TimeInterval = 0.5
        static let pulseAnimationDuration: TimeInterval = 0.3
        static let toastSize: CGFloat = 120
        static let checkmarkSize: CGFloat = 70
    }
    
    // MARK: - Properties
    
    var showItem: ShowItem?
    private var showIDString: String = ""
    private var detailsArray: [DetailInfo] = []
    private var processedSummary: String?
    private var isProcessingSummary = false
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var ratingImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var infoTableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        prepareDetailsArray()
        setupTableView()
        preprocessSummary()
        
        if #available(iOS 15.0, *) {
            infoTableView.sectionHeaderTopPadding = 0
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        setupPosterImageView()
        setupLabels()
        setupRatingImageView()
        setupBackgroundImageView()
    }
    
    private func setupPosterImageView() {
        posterImageView.layer.cornerRadius = UIConstants.posterCornerRadius
        posterImageView.clipsToBounds = true
        posterImageView.layer.zPosition = 1
    }
    
    private func setupLabels() {
        nameLabel.font = UIFont.systemFont(ofSize: UIConstants.namesFontSize, weight: .bold)
        nameLabel.layer.zPosition = 1
        ratingLabel.font = UIFont.systemFont(ofSize: UIConstants.ratingFontSize, weight: .semibold)
    }
    
    private func setupRatingImageView() {
        ratingImageView.tintColor = UIColor.systemYellow
        ratingImageView.image = UIImage(systemName: "star.fill")
    }
    
    private func setupBackgroundImageView() {
        backgroundImageView.contentMode = .scaleToFill
    }
    
    private func setupTableView() {
        infoTableView.delegate = self
        infoTableView.dataSource = self
        registerTableViewCells()
        configureTableViewAppearance()
    }
    
    private func registerTableViewCells() {
        infoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
        infoTableView.register(SectionDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
    }
    
    private func configureTableViewAppearance() {
        infoTableView.backgroundColor = .darkGrayBackground
        infoTableView.separatorStyle = .singleLine
        infoTableView.separatorInset = UIEdgeInsets.zero
        infoTableView.separatorColor = UIColor.black
        infoTableView.showsVerticalScrollIndicator = false
        infoTableView.contentInset = .zero
        infoTableView.contentInsetAdjustmentBehavior = .never
        infoTableView.sectionHeaderTopPadding = 0
        infoTableView.clipsToBounds = true
        infoTableView.layer.cornerRadius = UIConstants.tableViewCornerRadius
        infoTableView.layer.borderWidth = UIConstants.tableViewBorderWidth
        infoTableView.layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        guard let showItem = showItem else { return }
        
        showIDString = showItem.id.codingKey.stringValue
        updateWatchlistButton()
        setupNameLabel(with: showItem.name)
        setupRatingDisplay()
        loadImages()
    }
    
    private func setupNameLabel(with name: String) {
        nameLabel.text = name
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byTruncatingTail
    }
    
    private func updateWatchlistButton() {
        let isWatchlisted = DataController.shared.watchlistedShows.showIDs.contains(showIDString)
        let imageName = isWatchlisted ? "checkmark.square.fill" : "plus.app"
        addButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func setupRatingDisplay() {
        if let averageRating = showItem?.rating {
            ratingLabel.text = "\(averageRating)"
            ratingLabel.isHidden = false
            ratingImageView.isHidden = false
        } else {
            ratingLabel.isHidden = true
            ratingImageView.isHidden = true
        }
    }
    
    private func loadImages() {
        guard let showItem = showItem else { return }
        
        Task {
            do {
                // Load poster image
                let posterImage = await APIController.shared.loadImage(from: showItem.imageUrl)
                
                // Load background image
                let backgroundURLString = try await DataController.shared.getBackgroundImage(idString: String(showItem.id))
                let backgroundImage = await APIController.shared.loadImage(from: backgroundURLString)
                
                await MainActor.run {
                    self.posterImageView.image = posterImage
                    self.backgroundImageView.image = backgroundImage
                }
                
            } catch {
                await MainActor.run {
                    self.posterImageView.image = APIController.shared.defaultImage
                    self.posterImageView.contentMode = .center
                }
            }
        }
    }
    
    // MARK: - Details Array Preparation
    
    private func prepareDetailsArray() {
        detailsArray = []
        guard let showItem = showItem else { return }
        
        addDetailIfPresent(key: NSLocalizedString("detailReleaseDate", comment: ""),
                          value: showItem.premiered?.isEmpty == false ? formatDate(showItem.premiered!) : nil)
        
        addDetailIfPresent(key: NSLocalizedString("detailGenres", comment: ""),
                          value: showItem.genres?.isEmpty == false ? showItem.genres!.joined(separator: ", ") : nil)
        
        addDetailIfPresent(key: NSLocalizedString("detailNetwork", comment: ""),
                          value: showItem.network?.isEmpty == false ? showItem.network : nil)
        
        addDetailIfPresent(key: NSLocalizedString("detailStatus", comment: ""),
                          value: showItem.status?.isEmpty == false ? showItem.status : nil)
        
        if let runtime = showItem.runtime, runtime > 0 {
            detailsArray.append(DetailInfo(key: NSLocalizedString("detailRuntime", comment: ""),
                                         value: "\(runtime) minutes",
                                         link: false))
        }
        
        addDetailIfPresent(key: NSLocalizedString("detailEnded", comment: ""),
                          value: showItem.ended?.isEmpty == false ? formatDate(showItem.ended!) : nil)
        
        if let officialSite = showItem.officialSite, !officialSite.isEmpty {
            detailsArray.append(DetailInfo(key: NSLocalizedString("detailOfficialSite", comment: ""),
                                         value: officialSite,
                                         link: true))
        }
        
        addDetailIfPresent(key: NSLocalizedString("detailIMDB", comment: ""),
                          value: showItem.imdb?.isEmpty == false ? showItem.imdb : nil)
    }
    
    private func addDetailIfPresent(key: String, value: String?) {
        guard let value = value else { return }
        detailsArray.append(DetailInfo(key: key, value: value, link: false))
    }
    
    // MARK: - Summary Processing
    
    private func preprocessSummary() {
        guard let summary = showItem?.summary, !summary.isEmpty else { return }
        
        isProcessingSummary = true
        let truncated = truncateText(summary, maxLength: UIConstants.summaryMaxLength)
        processedSummary = truncated.text
        
        DataController.shared.removeHTMLTags(from: summary) { [weak self] modifiedSummary in
            Task { @MainActor in
                self?.processedSummary = modifiedSummary
                self?.isProcessingSummary = false
                
                if let summarySection = DetailViewController.SectionManager.getSectionIndex(for: .summary, in: self?.showItem) {
                    self?.infoTableView.reloadSections(IndexSet(integer: summarySection), with: .none)
                }
            }
        }
    }
    
    private func truncateText(_ text: String, maxLength: Int) -> TruncatedText {
        if text.count <= maxLength {
            return TruncatedText(text: text, isTruncated: false)
        }
        
        let truncated = String(text.prefix(maxLength)) + "..."
        return TruncatedText(text: truncated, isTruncated: true)
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d MMM yyyy"
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    // MARK: - IBActions
    
    @IBAction private func addToWatchlist(_ sender: UILongPressGestureRecognizer) {
        DataController.shared.updateWatchlist(showID: showIDString)
        updateWatchlistButton()
        
        if DataController.shared.watchlistedShows.showIDs.contains(showIDString) {
            showAnimatedCheckmarkToast()
        }
    }
}

// MARK: - Section Management

private extension DetailViewController {
    
    struct SectionManager {
        
        static func getSectionIndex(for sectionType: InfoSection, in showItem: ShowItem?) -> Int? {
            var currentIndex = 0
            
            if let summary = showItem?.summary, !summary.isEmpty {
                if sectionType == .summary {
                    return currentIndex
                }
                currentIndex += 1
            }
            
            if hasDetailsSection(in: showItem) {
                if sectionType == .details {
                    return currentIndex
                }
                currentIndex += 1
            }
            
            if let scheduleDays = showItem?.scheduleDays, !scheduleDays.isEmpty {
                if sectionType == .schedule {
                    return currentIndex
                }
            }
            
            return nil
        }
        
        static func getSectionType(for index: Int, in showItem: ShowItem?) -> InfoSection? {
            var currentIndex = 0
            
            if let summary = showItem?.summary, !summary.isEmpty {
                if currentIndex == index {
                    return .summary
                }
                currentIndex += 1
            }
            
            if hasDetailsSection(in: showItem) {
                if currentIndex == index {
                    return .details
                }
                currentIndex += 1
            }
            
            if let scheduleDays = showItem?.scheduleDays, !scheduleDays.isEmpty {
                if currentIndex == index {
                    return .schedule
                }
            }
            
            return nil
        }
        
        private static func hasDetailsSection(in showItem: ShowItem?) -> Bool {
                    guard let showItem = showItem else { return false }
                    
                    // Check if any detail information is available
                    let hasPremiered = showItem.premiered?.isEmpty == false
                    let hasGenres = showItem.genres?.isEmpty == false
                    let hasNetwork = showItem.network?.isEmpty == false
                    let hasStatus = showItem.status?.isEmpty == false
                    let hasRuntime = showItem.runtime != nil && showItem.runtime! > 0
                    let hasEnded = showItem.ended?.isEmpty == false
                    let hasOfficialSite = showItem.officialSite?.isEmpty == false
                    let hasIMDB = showItem.imdb?.isEmpty == false
                    
                    return hasPremiered || hasGenres || hasNetwork || hasStatus ||
                           hasRuntime || hasEnded || hasOfficialSite || hasIMDB
        }
    }
}

// MARK: - Cell Creation

private extension DetailViewController {
    
    func createSummaryCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = infoTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.backgroundColor = .cellBackground
        cell.selectionStyle = .none
        
        var content = cell.defaultContentConfiguration()
        
        if let processedSummary = processedSummary {
            let truncated = truncateText(processedSummary, maxLength: UIConstants.summaryMaxLength)
            content.text = truncated.text
            
            if truncated.isTruncated {
                let readMoreButton = createReadMoreButton(fullText: processedSummary)
                cell.accessoryView = readMoreButton
            } else {
                cell.accessoryView = nil
            }
        } else {
            let truncated = truncateText(showItem?.summary ?? "", maxLength: UIConstants.summaryMaxLength)
            content.text = truncated.text
            
            if truncated.isTruncated {
                let readMoreButton = createReadMoreButton(fullText: showItem?.summary ?? "")
                cell.accessoryView = readMoreButton
            } else {
                cell.accessoryView = nil
            }
        }
        
        content.textProperties.font = UIFont.systemFont(ofSize: 16)
        content.textProperties.color = .white
        content.textProperties.numberOfLines = 0
        
        cell.contentConfiguration = content
        return cell
    }
    
    func createDetailCell(at indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < detailsArray.count else {
            return infoTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        }
        
        let detailInfo = detailsArray[indexPath.row]
        
        if detailInfo.link {
            return createLinkCell(with: detailInfo.value, title: detailInfo.key, at: indexPath)
        }
        
        let cell = infoTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.backgroundColor = .cellBackground
        cell.selectionStyle = .none
        cell.accessoryView = nil
        cell.accessoryType = .none
        
        var content = cell.defaultContentConfiguration()
        
        content.text = detailInfo.key
        content.textProperties.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        content.textProperties.color = .lightGrayText
        
        content.secondaryText = detailInfo.value
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 16)
        content.secondaryTextProperties.color = .white
        content.textToSecondaryTextVerticalPadding = 4
        
        cell.contentConfiguration = content
        return cell
    }
    
    func createScheduleCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = infoTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.backgroundColor = .cellBackground
        cell.selectionStyle = .none
        cell.accessoryView = nil
        cell.accessoryType = .none
        
        var content = cell.defaultContentConfiguration()
        
        if let days = showItem?.scheduleDays, indexPath.row < days.count {
            content.text = NSLocalizedString("detailSchedule", comment: "")
            content.textProperties.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            content.textProperties.color = .lightGrayText
            
            var scheduleText = days[indexPath.row]
            if let time = showItem?.scheduleTime, !time.isEmpty {
                scheduleText += " at \(time)"
            }
            
            content.secondaryText = scheduleText
            content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 16)
            content.secondaryTextProperties.color = .white
            content.textToSecondaryTextVerticalPadding = 4
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func createLinkCell(with url: String, title: String, at indexPath: IndexPath) -> UITableViewCell {
        let cell = infoTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        
        cell.accessoryView = nil
        cell.accessoryType = .none
        cell.backgroundColor = .cellBackground
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        
        var content = cell.defaultContentConfiguration()
        
        content.text = title
        content.textProperties.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        content.textProperties.color = .lightGrayText
        
        content.secondaryText = url
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 16)
        content.secondaryTextProperties.color = .systemBlue
        content.textToSecondaryTextVerticalPadding = 4
        
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - Read More Functionality

private extension DetailViewController {
    
    func createReadMoreButton(fullText: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("detailReadMore", comment: ""), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.sizeToFit()
        button.addTarget(self, action: #selector(showFullSummaryPopup(_:)), for: .touchUpInside)
        button.accessibilityHint = fullText
        return button
    }
    
    @objc func showFullSummaryPopup(_ sender: UIButton) {
        guard let fullText = sender.accessibilityHint else { return }
        showSimpleSummaryViewController(with: fullText)
    }
    
    func showSimpleSummaryViewController(with text: String) {
        let summaryViewController = UIViewController()
        summaryViewController.view.backgroundColor = UIColor.systemBackground
        summaryViewController.title = NSLocalizedString("titleFullSummary", comment: "")
        
        let navController = UINavigationController(rootViewController: summaryViewController)
        
        summaryViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissSummaryViewController)
        )
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.textColor = .label
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        summaryViewController.view.addSubview(scrollView)
        scrollView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: summaryViewController.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: summaryViewController.view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: summaryViewController.view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: summaryViewController.view.safeAreaLayoutGuide.bottomAnchor),
            
            textLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            textLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            textLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc func dismissSummaryViewController() {
        dismiss(animated: true)
    }
}

// MARK: - URL Handling

private extension DetailViewController {
    
    func openURL(_ urlString: String) {
        var finalURLString = urlString
        
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            finalURLString = "https://" + urlString
        }
        
        guard let url = URL(string: finalURLString) else { return }
        
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemBlue
        present(safariVC, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        
        if let summary = showItem?.summary, !summary.isEmpty {
            count += 1
        }
        
        if !detailsArray.isEmpty {
            count += 1
        }
        
        if let scheduleDays = showItem?.scheduleDays, !scheduleDays.isEmpty {
            count += 1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let infoSection = SectionManager.getSectionType(for: section, in: showItem) else { return 0 }
        
        switch infoSection {
        case .summary:
            return 1
        case .details:
            return detailsArray.count
        case .schedule:
            return showItem?.scheduleDays.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let infoSection = SectionManager.getSectionType(for: indexPath.section, in: showItem) else {
            return tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        }
        
        switch infoSection {
        case .summary:
            return createSummaryCell(at: indexPath)
        case .details:
            return createDetailCell(at: indexPath)
        case .schedule:
            return createScheduleCell(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let infoSection = SectionManager.getSectionType(for: indexPath.section, in: showItem) else { return }
        
        if infoSection == .details && indexPath.row < detailsArray.count {
            let detailInfo = detailsArray[indexPath.row]
            
            if detailInfo.link {
                openURL(detailInfo.value)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as? SectionDetailHeaderView,
              let infoSection = SectionManager.getSectionType(for: section, in: showItem) else { return nil }
        
        headerView.configure(with: infoSection.title)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let infoSection = SectionManager.getSectionType(for: indexPath.section, in: showItem) else { return 44 }
        
        switch infoSection {
        case .summary:
            return UITableView.automaticDimension
        case .details, .schedule:
            return 60
        }
    }
}

// MARK: - Animated Checkmark Toast

extension DetailViewController {
    
    func showAnimatedCheckmarkToast(duration: TimeInterval = AnimationConstants.toastDuration) {
        let toastContainer = createToastContainer()
        let checkmarkView = createCheckmarkView()
        
        toastContainer.addSubview(checkmarkView)
        view.addSubview(toastContainer)
        
        setupToastConstraints(toastContainer: toastContainer, checkmarkView: checkmarkView)
        animateToastAppearance(toastContainer, checkmarkView: checkmarkView, duration: duration)
    }
    
    private func createToastContainer() -> UIView {
        let container = UIView()
        container.layer.zPosition = 1
        container.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        container.layer.cornerRadius = 30
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }
    
    private func createCheckmarkView() -> CheckmarkView {
        let checkmarkView = CheckmarkView(frame: .zero)
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        return checkmarkView
    }
    
    private func setupToastConstraints(toastContainer: UIView, checkmarkView: CheckmarkView) {
        NSLayoutConstraint.activate([
            toastContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            toastContainer.widthAnchor.constraint(equalToConstant: AnimationConstants.toastSize),
            toastContainer.heightAnchor.constraint(equalToConstant: AnimationConstants.toastSize),
            
            checkmarkView.centerXAnchor.constraint(equalTo: toastContainer.centerXAnchor),
            checkmarkView.centerYAnchor.constraint(equalTo: toastContainer.centerYAnchor),
            checkmarkView.widthAnchor.constraint(equalToConstant: AnimationConstants.checkmarkSize),
            checkmarkView.heightAnchor.constraint(equalToConstant: AnimationConstants.checkmarkSize)
        ])
    }
    
    private func animateToastAppearance(_ toastContainer: UIView, checkmarkView: CheckmarkView, duration: TimeInterval) {
        toastContainer.alpha = 0
        toastContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: AnimationConstants.fadeAnimationDuration, animations: {
            toastContainer.alpha = 1
            toastContainer.transform = CGAffineTransform.identity
        }) { _ in
            self.generateHapticFeedback(style: .medium)
            
            checkmarkView.animate(completion: {
                self.generateHapticFeedback(style: .heavy)
            })
            
            UIView.animate(withDuration: AnimationConstants.fadeAnimationDuration, delay: duration, options: [], animations: {
                toastContainer.alpha = 0
                toastContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                toastContainer.removeFromSuperview()
            }
        }
    }
    
    private func generateHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - Supporting Types

enum InfoSection: Int, CaseIterable {
    case summary = 0
    case details
    case schedule
    
    var title: String {
        switch self {
        case .summary: return NSLocalizedString("detailTitleSummary", comment: "")
        case .details: return NSLocalizedString("detailTitleInformation", comment: "")
        case .schedule: return NSLocalizedString("detailTitleSchedule", comment: "")
        }
    }
}

struct DetailInfo {
    let key: String
    let value: String
    let link: Bool
}

private struct TruncatedText {
    let text: String
    let isTruncated: Bool
}

// MARK: - UIColor Extensions

extension UIColor {
    static let darkGrayBackground = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
    static let lightGrayText = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
    static let cellBackground = UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1.0)
}
