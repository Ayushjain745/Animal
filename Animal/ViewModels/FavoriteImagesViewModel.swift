//
//  FavoriteImagesViewModel.swift
//  Animal
//
//  Created by Ayush Jain on 24/07/24.
//

import Foundation
import CoreData

class FavoriteImagesViewModel {
    private let coreDataManager = CoreDataManager.shared
    var favoriteImages = [FavoriteImage]()
    var filteredImages = [FavoriteImage]()
    var onImagesUpdate: (() -> Void)?
    
    // Fetches favorite images from Core Data and updates the filteredImages
    func fetchFavoriteImages() {
        favoriteImages = coreDataManager.fetchFavoriteImages()
        filteredImages = favoriteImages
        onImagesUpdate?()
    }
    
    // Filters the favorite images based on the specified animal name
    func filterImages(by animal: String) {
        if animal == "All" {
            filteredImages = favoriteImages
        } else {
            filteredImages = favoriteImages.filter { $0.animalName == animal }
        }
        onImagesUpdate?()
    }
}

