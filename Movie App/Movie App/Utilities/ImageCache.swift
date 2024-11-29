//
//  ImageCache.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 29.11.2024.
//

import Foundation
import UIKit

class ImageCache {
    static let sharedInstance = ImageCache()

    private let cache = NSCache<NSString, UIImage>()

    func saveImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
}
