//
//  BookAPI.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import Foundation

struct BookAPI {
    static func searchBooks(byTitle title: String, completion: @escaping (Result<[Book], Error>) -> Void) {
        // Encode the title to be URL-safe
        guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(encodedTitle)") else {
            return completion(.failure(NSError(domain: "Invalid title", code: -1)))
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let data = data else {
                return completion(.failure(NSError(domain: "No data", code: -1)))
            }

            do {
                let decoded = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
                let books = decoded.items.map { item in
                    let isbn13 = item.volumeInfo.industryIdentifiers?
                            .first(where: { $0.type == "ISBN_13" })?.identifier
                    return Book(
                        title: item.volumeInfo.title,
                        author: item.volumeInfo.authors?.first ?? "Unknown",
                        collectionID: "",
                        isbn: item.volumeInfo.industryIdentifiers?
                            .first(where: { $0.type == "ISBN_13" })?.identifier, // extract from industryIdentifiers
                        thumbnailURL: item.volumeInfo.imageLinks?.thumbnail,
                        description: item.volumeInfo.description,
                        publisher: item.volumeInfo.publisher,
                        year: item.volumeInfo.publishedDate
                    )
                }
                completion(.success(books))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

// MARK: - Google Books API Models

struct GoogleBooksResponse: Decodable {
    let items: [GoogleBookItem]
}

struct GoogleBookItem: Decodable {
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Decodable {
    let title: String
    let authors: [String]?
    let description: String?
    let publisher: String?
    let publishedDate: String?
    let imageLinks: ImageLinks?
    let industryIdentifiers: [IndustryIdentifier]?
}

struct IndustryIdentifier: Decodable {
    let type: String
    let identifier: String
}

struct ImageLinks: Decodable {
    let thumbnail: String?
}
