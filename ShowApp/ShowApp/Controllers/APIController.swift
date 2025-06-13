//
//  APIController.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 01.04.2024.
//

import Foundation
import UIKit

class APIController {
    
    static let shared = APIController()
    
    // MARK: - Private Properties
    private let showsURL: String = "shows/"
    private let imagesURL: String = "/images"
    private let searchShowsURL: String = "search/shows?q="
    private let baseURL: String = "https://api.tvmaze.com/"
    
    // MARK: - Public Properties
    let defaultImage = UIImage(systemName: "photo.on.rectangle.angled",
                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 100))
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Public Methods
    
    /// Fetches show data from the API
    /// - Parameter idString: The ID of the show to fetch
    /// - Returns: Raw data from the API
    /// - Throws: APIError if the request fails
    func getShow(idString: String) async throws -> Data {
        guard let url = URL(string: baseURL + showsURL + idString) else {
            print("Error: Invalid URL")
            throw APIError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    /// Fetches images for a show from the API
    /// - Parameter idString: The ID of the show
    /// - Returns: Raw image data from the API
    /// - Throws: APIError if the request fails
    func getImages(idString: String) async throws -> Data {
        guard let url = URL(string: baseURL + showsURL + idString + imagesURL) else {
            print("Error: Invalid URL")
            throw APIError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    /// Searches for shows using the API
    /// - Parameter searchString: The search query
    /// - Returns: Raw search results data
    /// - Throws: APIError if the request fails
    func getSearch(searchString: String) async throws -> Data {
        guard let url = URL(string: baseURL + searchShowsURL + searchString) else {
            print("Error: Invalid URL")
            throw APIError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    /// Loads an image from a URL with caching
    /// - Parameter urlString: The URL string of the image
    /// - Returns: The loaded UIImage or default image
    func loadImage(from urlString: String?) async -> UIImage {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return defaultImage ?? UIImage()
        }

        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(forKey: urlString) {
            return cachedImage
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            if let image = UIImage(data: data) {
                ImageCache.shared.saveImage(image, forKey: urlString)
                return image
            } else {
                return defaultImage ?? UIImage()
            }
        } catch {
            print("Image loading error: \(error)")
            return defaultImage ?? UIImage()
        }
    }
    
    // MARK: - Private Methods
    
    /// Performs a generic HTTP GET request
    /// - Parameter url: The URL to request
    /// - Returns: Raw data from the response
    /// - Throws: APIError for various failure cases
    private func performRequest(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.requestFailed
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 401, 403:
                print("Error: Unauthorized or Forbidden")
                throw APIError.unauthorized
            case 404:
                print("Error: Not Found")
                throw APIError.notFound
            default:
                print("Error: Request failed with status code \(httpResponse.statusCode)")
                throw APIError.requestFailed
            }
        } catch let error as APIError {
            throw error
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError
        }
    }
}
