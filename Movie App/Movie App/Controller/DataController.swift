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
    func getBackgroundImage(idString: String, onSuccess: @escaping (String) -> Void, onFailure: @escaping () -> Void) {
        // Call the function to get images
        
        getImages(idString: idString) { Images in
            // Iterate through the images received
            if Images.isEmpty {
                onFailure()
            } else {
                for image in Images {
                    if image.type == "background" {
                        onSuccess(image.resolutions.original.url)
                        // Break out of the loop since we found the background image
                        break
                    } else {
                        onFailure()
                    }
                }
            }
            
        } onFailure: {
            // Handle failure case
            onFailure()
        } onErrorAuth: {
            // Handle authentication error case
            onFailure()
        } onErrorJSON: {
            // Handle JSON error case
            onFailure()
        }
    }
    
    
    
    // MARK: - Get and Decode Show
    func getShow(idString: String) async throws -> ShowModel {
        let data = try await APIController.sharedInstance.getShowAPI(idString: idString)
        do {
            let showModel = try JSONDecoder().decode(ShowModel.self, from: data)
            return showModel
        } catch {
            throw DataError.decodingError
        }
    }
    
    // MARK: - Get and Decode Images
    func getImages(idString:String,onSuccess:@escaping ([ImageModel]) -> Void, onFailure:@escaping () -> Void, onErrorAuth:@escaping () -> Void, onErrorJSON:@escaping () -> Void)
    {
        // Call the API to get the images data
        APIController.sharedInstance.getImagesAPI(idString: idString) { data in
            do {
                // Decode the JSON data into a ImageModel object
                let imageModel = try JSONDecoder().decode([ImageModel].self, from: data)
                onSuccess(imageModel)
            }
            catch
            {
                // Handle JSON decoding error
                print("Error decoding JSON: \(error)")
                onErrorJSON()
            }
            
        } onError: {
            // Handle general error case
            onFailure()
        } onErrorAuth: {
            // Handle authentication error case
            onErrorAuth()
        }
        
    }
    
    // MARK: - Get and Decode Search
    func getSearch(searchString:String, onSuccess: @escaping ([SearchShowModel]) -> Void, onFailure: @escaping () -> Void,onErrorAuth:@escaping () -> Void, onErrorJSON:@escaping () -> Void) {
        // Call the API to get the search data
        APIController.sharedInstance.getSearchAPI(searchString: searchString) { data in
            do {
                // Decode the JSON data into a SearchShowModel object
                let searchShowModel = try JSONDecoder().decode([SearchShowModel].self, from: data)
                onSuccess(searchShowModel)
            }
            catch
            {
                // Handle JSON decoding error
                print("Error decoding JSON: \(error)")
                onErrorJSON()
            }
        } onError: {
            // Handle general error case
            onFailure()
        } onErrorAuth: {
            // Handle authentication error case
            onErrorAuth()
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
