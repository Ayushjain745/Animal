//
//  AnimalService.swift
//  Animal
//
//  Created by Ayush Jain on 24/07/24.
//

import Foundation

class AnimalService {
    
    // Fetches pictures for a specific animal from the Pexels API
    func fetchPictures(for animal: String, page: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        // Constructs the Pexels API URL with the given animal query and page number
        let urlString = "https://api.pexels.com/v1/search?query=\(animal)&page=\(page)&per_page=15"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        
        if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String {
            request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        }
        
        // Performs the network request
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                // Handles error in network request
                completion(.failure(error))
                return
            }
            guard let data = data else {
                // Handles case where no data is returned
                completion(.failure(NSError(domain: "Data Error", code: -1, userInfo: nil)))
                return
            }
            do {
                // Decodes JSON response into PexelsResponse model
                let response = try JSONDecoder().decode(PexelsResponse.self, from: data)
                // Maps the decoded response to an array of picture URLs
                let pictureURLs = response.photos.map { $0.src.original }
                completion(.success(pictureURLs))
            } catch {
                // Handles error in JSON decoding
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
