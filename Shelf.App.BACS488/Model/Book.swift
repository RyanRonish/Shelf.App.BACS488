//
//  Book.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import Foundation
import FirebaseFirestore

struct Book: Identifiable, Codable, Equatable {
    var id: String?
    let title: String
    let author: String
    let collectionID: String
    let isbn: String?
    let thumbnailURL: String?

    // 🔹 New optional fields for autofill
    let description: String?
    let publisher: String?
    let year: String?

    // ✅ Implement Equatable Protocol
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.author == rhs.author &&
               lhs.collectionID == rhs.collectionID &&
               lhs.isbn == rhs.isbn &&
               lhs.thumbnailURL == rhs.thumbnailURL &&
               lhs.description == rhs.description &&
               lhs.publisher == rhs.publisher &&
               lhs.year == rhs.year
    }
}


