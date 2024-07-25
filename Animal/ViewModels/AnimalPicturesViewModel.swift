//
//  AnimalPicturesViewModel.swift
//  Animal
//
//  Created by Ayush Jain on 24/07/24.
//

import Foundation

class AnimalPicturesViewModel {
    private let animalService: AnimalServiceProtocol
    private var currentPage = 1
    private var isLoading = false
    private var animalName: String?
    
    var pictures: [String] = [] {
        didSet {
            onPicturesUpdate?()
        }
    }
    
    var onPicturesUpdate: (() -> Void)?
    
    init(animalService: AnimalServiceProtocol = AnimalService()) {
        self.animalService = animalService
    }
    
    // Fetches pictures for the specified animal, starting at the current page
    func fetchAnimalPictures(for animal: String) {
        guard !isLoading else { return }
        isLoading = true
        self.animalName = animal
        animalService.fetchPictures(for: animal, page: currentPage) { [weak self] result in
            switch result {
            case .success(let newPictures):
                DispatchQueue.main.async {
                    if self?.currentPage == 1 {
                        self?.pictures = newPictures
                    } else {
                        self?.pictures.append(contentsOf: newPictures)
                    }
                    self?.isLoading = false
                    self?.onPicturesUpdate?()
                }
            case .failure:
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.onPicturesUpdate?()
                }
            }
        }
    }
    
    // Loads more pictures for the current animal by incrementing the page number
    func loadMorePictures() {
        guard let animal = animalName, !isLoading else { return }
        currentPage += 1
        fetchAnimalPictures(for: animal)
    }
    
    // Toggles the favorite status for a given picture URL
    func toggleFavoriteStatus(for url: String, animalName: String, completion: @escaping (Bool) -> Void) {
        CoreDataManager.shared.toggleFavoriteStatus(for: url, animalName: animalName) { success in
            completion(success)
        }
    }
    
    // Checks if a given picture URL is marked as favorite
    func isFavorite(_ url: String) -> Bool {
        return CoreDataManager.shared.isFavorite(url)
    }
}
