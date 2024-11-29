//
//  APIController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 01.04.2024.
//

import Foundation
import UIKit

class APIController {
    
    static var sharedInstance = APIController()
    
    // URL from TVMaze
    private let showsURL:String = "shows/"
    private let imagesURL:String = "/images"
    private let searchShowsURL:String = "search/shows?q="
    private let baseURL:String = "https://api.tvmaze.com/"
    
    // Set a default image
    let defaultImage = UIImage(systemName: "photo.on.rectangle.angled")
    
    // MARK: - Getting Show From API
    func getShowAPI(idString: String) async throws -> Data {
        guard let url = URL(string: baseURL + showsURL + idString) else {
            print("Error: Invalid URL")
            throw APIError.invalidURL
        }
        
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
    
    // MARK: - Getting Images From API
    func getImagesAPI(idString:String) async throws -> Data
    {
        guard let url = URL(string: baseURL + showsURL + idString + imagesURL) else {
            print("Error: Invalid URL")
            throw APIError.invalidURL
        }
        
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
                print("Error: \(httpResponse.statusCode)")
                throw APIError.requestFailed
            }
        } catch let error as APIError {
            throw error
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError
        }
    }
    // MARK: - Getting Search From API
    func getSearchAPI(searchString:String) async throws -> Data
    {
        guard let url = URL(string: baseURL + searchShowsURL + searchString) else {
            print("Error: Invalid URL")
            throw APIError.invalidURL
        }
        
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
                print("Error: \(httpResponse.statusCode)")
                throw APIError.requestFailed
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError
        }
    }
    
    // MARK: - Load Image
    func loadImage(from urlString: String?) async -> UIImage {
        // Check that the URL is valid
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return self.defaultImage ?? UIImage()
        }

        // Check if the image is already cached
        if let cachedImage = ImageCache.sharedInstance.getImage(forKey: urlString) {
            return cachedImage
        }

        do {
            // Download data via URLSession
            let (data, _) = try await URLSession.shared.data(from: url)

            // Creating an image from downloaded data
            if let image = UIImage(data: data) {
                // Save to cache
                ImageCache.sharedInstance.saveImage(image, forKey: urlString)
                return image
            } else {
                // Return a default image if the data is invalid
                return self.defaultImage ?? UIImage()
            }
        } catch {
            // Log the error and return a default image
            print("Image loading error: \(error)")
            return self.defaultImage ?? UIImage()
        }
    }
}

