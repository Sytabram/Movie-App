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
    func getShowAPI(idString:String, onSuccess: @escaping(Data) -> Void, onError: @escaping() -> Void, onErrorAuth: @escaping() -> Void)
    {
        let url : String =  baseURL + showsURL + idString
        let request : NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
        guard let _ = data,
                let response = response as? HTTPURLResponse,
                error == nil else {   // check for fundamental networking error
                onError()
                return
            }
            if (403 == response.statusCode || 401 == response.statusCode) {   // check Authorized
                onErrorAuth()
                return
            }
            guard (200 ... 299) ~= response.statusCode else {   // check for http errors
                onError()
                return
            }
            onSuccess(data!)
        }
        task.resume()
    }
    
    // MARK: - Getting Images From API
    func getImagesAPI(idString:String, onSuccess: @escaping(Data) -> Void, onError: @escaping() -> Void, onErrorAuth: @escaping() -> Void)
    {
        let url : String =  baseURL + showsURL + idString + imagesURL
        let request : NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
        guard let _ = data,
                let response = response as? HTTPURLResponse,
                error == nil else {   // check for fundamental networking error
                onError()
                return
            }
            if (403 == response.statusCode || 401 == response.statusCode) {   // check Authorized
                onErrorAuth()
                return
            }
            guard (200 ... 299) ~= response.statusCode else {   // check for http errors
                onError()
                return
            }
            onSuccess(data!)
        }
        task.resume()
    }
    // MARK: - Getting Search From API
    func getSearchAPI(searchString:String, onSuccess: @escaping(Data) -> Void, onError: @escaping() -> Void, onErrorAuth: @escaping() -> Void)
    {
        let url : String =  baseURL + searchShowsURL + searchString
        let request : NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
        guard let _ = data,
                let response = response as? HTTPURLResponse,
                error == nil else {   // check for fundamental networking error
                onError()
                return
            }
            if (403 == response.statusCode || 401 == response.statusCode) {   // check Authorized
                onErrorAuth()
                return
            }
            guard (200 ... 299) ~= response.statusCode else {   // check for http errors
                onError()
                return
            }
            onSuccess(data!)
        }
        task.resume()
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
