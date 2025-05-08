//
//  BookCollection.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import Foundation
import FirebaseFirestore
import SwiftUI


class BookCollection: ObservableObject, Identifiable, Codable {
    @DocumentID var id: String?  // Use a String ID to align with Firestore document IDs
    @Published var name: String
    @Published var books: [Book]
    @Published var ownerId: String

    enum CodingKeys: String, CodingKey {
        case id, name, books, ownerId
    }

    init(name: String, ownerId: String, books: [Book] = []) {
        self.name = name
        self.ownerId = ownerId
        self.books = books
    }

    // MARK: - Encoding & Decoding for Firebase
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        ownerId = try container.decode(String.self, forKey: .ownerId)  // Decode ownerId
        books = try container.decode([Book].self, forKey: .books)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(ownerId, forKey: .ownerId)  // Encode ownerId
        try container.encode(books, forKey: .books)
    }
}

