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
    let isbn: String?
    let thumbnailURL: String?

    // ✅ Implement Equatable Protocol
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.author == rhs.author &&
               lhs.isbn == rhs.isbn &&
               lhs.thumbnailURL == rhs.thumbnailURL
    }
}

/*
struct Book: Identifiable, Codable {
   // @DocumentID var id: String?
    let id = UUID()
    let title: String
    let author: String
    let isbn: String
    let thumbnailURL: String?
}
*/
