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
    func loadImage(from urlString: String?, completion: @escaping (UIImage) -> Void) {
        // Convert the URL string to URL
        DispatchQueue.main.async {
            if urlString != nil {
                guard let url = URL(string: urlString!) else {
                    // If the URL is invalid, return a default image and exit the function
                    completion(self.defaultImage!)
                    return
                }
                // Perform a URLSession task to download the image from the URL
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        // In case of error, print a debug message, return a default image, and exit the function
                        print("Image loading error : \(error)")
                        completion(self.defaultImage!)
                        return
                    }
                    // Check if data was returned and an image can be created from that data
                    if let data = data, let image = UIImage(data: data) {
                        // If the image was successfully downloaded, pass it to the completion closure
                        completion(image)
                    } else {
                        // If the data is nil or the image cannot be created, return a default image
                        completion(self.defaultImage!)
                    }
                }.resume() // Launch the URLSession task to start downloading the image
            } else {
                completion(self.defaultImage!)
            }
        }
        
    }

}
