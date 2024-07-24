//
//  AnimalPicturesViewModel.swift
//  Animal
//
//  Created by Ayush Jain on 24/07/24.
//

import Foundation

class AnimalPicturesViewModel {
    private let animalService: AnimalService
    private var currentPage = 1
    private var isLoading = false
    private var animalName: String?
    
    var pictures: [String] = [] {
        didSet {
            onPicturesUpdate?()
        }
    }
    
    var onPicturesUpdate: (() -> Void)?
    
    init(animalService: AnimalService = AnimalService()) {
        self.animalService = animalService
    }
    
    func fetchAnimalPictures(for animal: String) {
        guard !isLoading else { return }
        isLoading = true
        self.animalName = animal
        animalService.fetchPictures(for: animal, page: currentPage) { [weak self] result in
            switch result {
            case .success(let newPictures):
                DispatchQueue.main.async {
                    self?.pictures = newPictures
                    self?.isLoading = false
                }
            case .failure:
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }
        }
    }
    
    func loadMorePictures() {
        guard let animal = animalName, !isLoading else { return }
        currentPage += 1
        fetchAnimalPictures(for: animal)
    }
    
    func toggleFavoriteStatus(for url: String, animalName: String, completion: @escaping (Bool) -> Void) {
        CoreDataManager.shared.toggleFavoriteStatus(for: url, animalName: animalName) { success in
            completion(success)
        }
    }
    
    func isFavorite(_ url: String) -> Bool {
        return CoreDataManager.shared.isFavorite(url)
    }
}

