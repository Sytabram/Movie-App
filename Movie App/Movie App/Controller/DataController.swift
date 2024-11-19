//
//  DataController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 01.04.2024.
//

import Foundation

class DataController {
    
    static var sharedInstance = DataController()
    
    struct Static {
        fileprivate static var instance: DataController?
    }

    // Set words to remove from summary
    private let wordsToRemove = ["<p>", "</p>", "<b>", "</b>"]
    
    // MARK: - Getting Home Shows Data
    func getCategoryShows() async throws -> [(String, [ShowModel])] {
        var showsCategoryList: [(String, [ShowModel])] = []

        for (category, ids) in ShowCategoryModel().categoryShowsID {
            var listOfShows = Array<ShowModel?>(repeating: nil, count: ids.count)

            try await withThrowingTaskGroup(of: (Int, ShowModel).self) { group in
                for (index, id) in ids.enumerated() {
                    group.addTask {
                        let show = try await self.getShow(idString: id)
                        return (index, show) 
                    }
                }

                for try await (index, show) in group {
                    listOfShows[index] = show
                }
            }
            showsCategoryList.append((category, listOfShows.compactMap { $0 }))
        }
        return showsCategoryList
    }
    
    
    // MARK: - Getting Background Image
    func getBackgroundImage(idString: String) async throws -> String {
        // Call the function to get images
        let images = try await getImages(idString: idString)
        
        // Check if the array is empty
        guard !images.isEmpty else {
            throw DataError.isEmpty
        }
        
        // Find the first image with type "background"
        if let backgroundImage = images.first(where: { $0.type == "background" }) {
            return backgroundImage.resolutions.original.url
        }
        
        // Throw an error if no background image was found
        throw DataError.imageBackgroundEmpty
    }
    
    
    
    // MARK: - Get and Decode Show
    func getShow(idString: String) async throws -> ShowModel {
        // Call the API to get the show data
        let data = try await APIController.sharedInstance.getShowAPI(idString: idString)
        do {
            // Decode the JSON data into a ShowModel object
            let showModel = try JSONDecoder().decode(ShowModel.self, from: data)
            return showModel
        } catch {
            // Handle JSON decoding error
            throw DataError.decodingError
        }
    }
    
    // MARK: - Get and Decode Images
    func getImages(idString:String) async throws -> [ImageModel]
    {
        // Call the API to get the images data
        let data = try await APIController.sharedInstance.getImagesAPI(idString: idString)
        do {
            // Decode the JSON data into a ImageModel object
            let imageModel = try JSONDecoder().decode([ImageModel].self, from: data)
            return imageModel
        } catch {
            // Handle JSON decoding error
            throw DataError.decodingError
        }
    }
    
    // MARK: - Get and Decode Search
    func getSearch(searchString:String) async throws -> [SearchShowModel]
    {
        // Call the API to get the search data
        let data = try await APIController.sharedInstance.getSearchAPI(searchString: searchString)
        do {
            // Decode the JSON data into a SearchShowModel object
            let searchShowModel = try JSONDecoder().decode([SearchShowModel].self, from: data)
            return searchShowModel
        } catch {
            // Handle JSON decoding error
            print("Error decoding JSON: \(error)")
            throw DataError.decodingError
        }
    }
    
    // MARK: - Remove words from string
    func removeWords(from sentenceString: String, completion: @escaping (String) -> Void){
        var sentence = sentenceString
        for wordToRemove in wordsToRemove {
            while let range = sentence.range(of: wordToRemove) {
                sentence.removeSubrange(range)
                completion(sentence)
            }
        }
    }
}
