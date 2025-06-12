//
//  ImageCache.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 29.11.2024.
//

import Foundation
import UIKit

class ImageCache {
    
    // MARK: - Singleton
    static let shared = ImageCache()
    
    // MARK: - Private Properties
    private let cache = NSCache<NSString, UIImage>()
    
    // MARK: - Initializer
    private init() {
        setupCache()
        setupMemoryManagement()
    }
    
    // MARK: - Setup Methods
    private func setupCache() {
        cache.countLimit = 50
        cache.totalCostLimit = 30 * 1024 * 1024

    }
    
    private func setupMemoryManagement() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    // MARK: - Public Methods
    
    /// Saves an image to the cache with automatic size calculation
    func saveImage(_ image: UIImage, forKey key: String) {
        let cost = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }

    /// Retrieves an image from the cache
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    // MARK: - Private Methods
    
    @objc private func handleMemoryWarning() {
        cache.removeAllObjects()
        print("🧹 Cache cleared due to memory warning")
    }
    
    @objc private func handleAppBackground() {
        let currentLimit = cache.countLimit
        cache.countLimit = currentLimit / 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.cache.countLimit = currentLimit
        }
        
        print("🧹 Cache reduced temporarily for background mode")
    }
    
    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
