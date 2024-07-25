//
//  AnimalServiceMock.swift
//  AnimalTests
//
//  Created by Ayush Jain on 24/07/24.
//

@testable import Animal
import Foundation

class MockAnimalService: AnimalServiceProtocol {
    var picturesToReturn: [String] = []
    var shouldReturnError = false
    
    func fetchPictures(for animal: String, page: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
        } else {
            completion(.success(picturesToReturn))
        }
    }
}


