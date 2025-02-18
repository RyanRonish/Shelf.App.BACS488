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
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)"

        guard let url = URL(string: urlString) else {
            print("Invalid API URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("DEBUG: API request failed - \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("DEBUG: No data received")
                completion(nil)
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)

                if let bookInfo = decodedResponse.items?.first?.volumeInfo {
                    let book = Book(
                        id: UUID().uuidString,
                        title: bookInfo.title ?? "Unknown Title",
                        author: bookInfo.authors?.joined(separator: ", ") ?? "Unknown Author",
                        isbn: isbn,
                        thumbnailURL: bookInfo.imageLinks?.thumbnail
                    )
                    completion(book)
                } else {
                    completion(nil)
                }
            } catch {
                print("Error decoding JSON: - \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}

// Structs to decode Google Books API response
struct GoogleBooksResponse: Codable {
    let items: [BookItem]?
}

struct BookItem: Codable {
    let volumeInfo: BookInfo
}

struct BookInfo: Codable {
    let title: String
    let authors: [String]?
    let imageLinks: ImageLinks?
}

struct ImageLinks: Codable {
    let thumbnail: String?
}


