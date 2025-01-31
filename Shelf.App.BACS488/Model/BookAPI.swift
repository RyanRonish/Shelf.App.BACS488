//
//  BookAPI.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import Foundation

class BookAPI {
    static let shared = BookAPI()

    func fetchBookDetails(isbn: String, completion: @escaping (Book?) -> Void) {
        let apiUrl = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)"

        guard let url = URL(string: apiUrl) else {
            print("Invalid API URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching book data:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }

            do {
                let jsonResponse = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)

                if let bookItem = jsonResponse.items?.first {
                    let book = Book(
                        id: bookItem.id,
                        title: bookItem.volumeInfo.title,
                        author: bookItem.volumeInfo.authors?.first ?? "Unknown",
                        isbn: isbn,
                        thumbnailURL: bookItem.volumeInfo.imageLinks?.thumbnail ?? "https://example.com/default-thumbnail.jpg"
                    )
                    completion(book)
                } else {
                    completion(nil)
                }
            } catch {
                print("Error decoding JSON:", error.localizedDescription)
                completion(nil)
            }
        }.resume()
    }
}

// Structs to decode Google Books API response
struct GoogleBooksResponse: Decodable {
    let items: [GoogleBookItem]?
}

struct GoogleBookItem: Decodable {
    let id: String
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Decodable {
    let title: String
    let authors: [String]?
    let imageLinks: ImageLinks?
}

struct ImageLinks: Decodable {
    let thumbnail: String?
}


