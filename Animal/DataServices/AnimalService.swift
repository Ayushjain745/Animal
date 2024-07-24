//
//  AnimalService.swift
//  Animal
//
//  Created by Ayush Jain on 24/07/24.
//

import Foundation

class AnimalService {
    private let apiKey = "F0RsC7L6viQO7bzFmZTKs7hwGWhXlwm5TjAozyXUwkTmB8INisxbwjVg"
    
    func fetchPictures(for animal: String, page: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        // Pexels API endpoint for search
        let urlString = "https://api.pexels.com/v1/search?query=\(animal)&page=\(page)&per_page=15"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "Data Error", code: -1, userInfo: nil)))
                return
            }
            do {
                // Decode JSON response
                let response = try JSONDecoder().decode(PexelsResponse.self, from: data)
                let pictureURLs = response.photos.map { $0.src.original }
                completion(.success(pictureURLs))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// Decodable structures for Pexels API response
struct PexelsResponse: Decodable {
    let photos: [Photo]
}

struct Photo: Decodable {
    let src: Src
}

struct Src: Decodable {
    let original: String
}
