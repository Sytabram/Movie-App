//
//  DataController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 01.04.2024.
//

import Foundation

class DataController {
    
    // MARK: - Singleton
    static let shared = DataController()
    private init() {}
    
    // MARK: - Properties
    var watchlistedShows: ShowCategory = ShowCategory(
        name: NSLocalizedString("categoryWatchlist", comment: ""),
        showIDs: []
    )
    
    private let wordsToRemove = [
        "<p>", "</p>", "<b>", "</b>", "<i>", "</i>",
        "<em>", "</em>", "<strong>", "</strong>",
        "<u>", "</u>", "<s>", "</s>"
    ]
    
    // MARK: - Public Methods
    
    /// Fetches and organizes shows by categories
    /// - Returns: Array of tuples containing category names and their shows
    /// - Throws: Various errors from API or decoding
    func getCategoryShows() async throws -> [(String, [Show])] {
        var orderedCategories: [(String, [Show])] = []
        var categoryModels = mockShowCategories
        
        // Insert watchlisted shows at the beginning if any exist
        if !watchlistedShows.showIDs.isEmpty {
            categoryModels.insert(watchlistedShows, at: 0)
        }
        
        // Process each category
        for category in categoryModels {
            var orderedShows = Array<Show?>(repeating: nil, count: category.showIDs.count)
            
            try await withThrowingTaskGroup(of: (Int, Show).self) { group in
                for (index, id) in category.showIDs.enumerated() {
                    group.addTask {
                        let show = try await self.getShow(idString: id)
                        return (index, show)
                    }
                }
                
                for try await (index, show) in group {
                    orderedShows[index] = show
                }
            }
            
            orderedCategories.append((category.name, orderedShows.compactMap { $0 }))
        }
        
        return orderedCategories
    }
    
    /// Fetches background image URL for a show
    /// - Parameter idString: The show ID
    /// - Returns: URL string of the background image
    /// - Throws: DataError if no background image is found
    func getBackgroundImage(idString: String) async throws -> String {
        let images = try await getImages(idString: idString)
        
        guard !images.isEmpty else {
            throw DataError.isEmpty
        }
        
        guard let backgroundImage = images.first(where: { $0.type == "background" }) else {
            throw DataError.imageBackgroundEmpty
        }
        
        return backgroundImage.resolutions.original.url
    }
    
    /// Fetches and decodes a single show
    /// - Parameter idString: The show ID
    /// - Returns: Decoded Show object
    /// - Throws: DataError.decodingError or APIError
    func getShow(idString: String) async throws -> Show {
        let data = try await APIController.shared.getShow(idString: idString)
        
        do {
            return try JSONDecoder().decode(Show.self, from: data)
        } catch {
            print("Show decoding error: \(error)")
            throw DataError.decodingError
        }
    }
    
    /// Fetches and decodes images for a show
    /// - Parameter idString: The show ID
    /// - Returns: Array of decoded Image objects
    /// - Throws: DataError.decodingError or APIError
    func getImages(idString: String) async throws -> [Image] {
        let data = try await APIController.shared.getImages(idString: idString)
        
        do {
            return try JSONDecoder().decode([Image].self, from: data)
        } catch {
            print("Images decoding error: \(error)")
            throw DataError.decodingError
        }
    }
    
    /// Searches for shows and decodes results
    /// - Parameter searchString: The search query
    /// - Returns: Array of search results
    /// - Throws: DataError.decodingError or APIError
    func getSearch(searchString: String) async throws -> [ShowSearchResult] {
        let data = try await APIController.shared.getSearch(searchString: searchString)
        
        do {
            return try JSONDecoder().decode([ShowSearchResult].self, from: data)
        } catch {
            print("Search decoding error: \(error)")
            throw DataError.decodingError
        }
    }
    
    /// Removes HTML tags from a string
    /// - Parameters:
    ///   - sentenceString: The string to clean
    ///   - completion: Completion handler with cleaned string
    func removeHTMLTags(from sentenceString: String, completion: @escaping (String) -> Void) {
        var cleanedString = sentenceString
        
        for tag in wordsToRemove {
            cleanedString = cleanedString.replacingOccurrences(of: tag, with: "")
        }
        
        completion(cleanedString)
    }
    
    // MARK: - Watchlist Management
    
    /// Updates the watchlist by adding or removing a show
    /// - Parameter showID: The ID of the show to toggle
    func updateWatchlist(showID: String) {
        if watchlistedShows.showIDs.contains(showID) {
            watchlistedShows.showIDs.removeAll { $0 == showID }
        } else {
            watchlistedShows.showIDs.append(showID)
        }
        saveWatchlist()
    }
    
    /// Saves the current watchlist to UserDefaults
    private func saveWatchlist() {
        do {
            let encoded = try JSONEncoder().encode(watchlistedShows)
            UserDefaults.standard.set(encoded, forKey: "savedWatchlist")
        } catch {
            print("Failed to save watchlist: \(error)")
        }
    }
    
    /// Loads the watchlist from UserDefaults
    func loadWatchlist() {
        guard let savedData = UserDefaults.standard.data(forKey: "savedWatchlist") else {
            return
        }
        
        do {
            watchlistedShows = try JSONDecoder().decode(ShowCategory.self, from: savedData)
        } catch {
            print("Failed to load watchlist: \(error)")
        }
    }
}
