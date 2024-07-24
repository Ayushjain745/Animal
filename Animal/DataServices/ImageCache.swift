//
//  ImageCache.swift
//  Animal
//
//  Created by Ayush Jain on 24/07/24.
//

import UIKit

class ImageCache {
    // Singleton instance of ImageCache
    static let shared = ImageCache()
    
    // NSCache to store images
    private let cache = NSCache<NSString, UIImage>()
    
    // Retrieves an image from the cache for the given key
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    // Stores an image in the cache with the given key
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

