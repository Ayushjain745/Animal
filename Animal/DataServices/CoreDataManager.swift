//
//  CoreDataManager.swift
//  Animal
//
//  Created by Ayush Jain on 24/07/24.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Animal")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                print("Failed to save context: \(error)")
            }
        }
    }
    
    func addFavoriteImage(url: String, animalName: String) {
        let favoriteImage = FavoriteImage(context: context)
        favoriteImage.url = url
        favoriteImage.animalName = animalName
        saveContext()
    }
    
    func fetchFavoriteImages() -> [FavoriteImage] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteImage> = FavoriteImage.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch favorite images: \(error)")
            return []
        }
    }
    
    func toggleFavoriteStatus(for url: String, animalName: String, completion: @escaping (Bool) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteImage> = FavoriteImage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", url)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingImage = results.first {
                // Toggle the favorite status
                existingImage.isFavorite.toggle()
            } else {
                // Add new favorite image
                let newImage = FavoriteImage(context: context)
                newImage.url = url
                newImage.animalName = animalName
                newImage.isFavorite = true
            }
            try context.save()
            completion(true)
        } catch {
            print("Failed to toggle favorite status: \(error)")
            completion(false)
        }
    }
    
    func isFavorite(_ url: String) -> Bool {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteImage> = FavoriteImage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", url)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first?.isFavorite ?? false
        } catch {
            print("Failed to check favorite status: \(error)")
            return false
        }
    }
}

