//
//  Book.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import Foundation
import FirebaseFirestore

struct Book: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var author: String
    var isbn: String?
    var thumbnailURL: String?

    init(id: String = UUID().uuidString, title: String, author: String, isbn: String? = nil, thumbnailURL: String? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.isbn = isbn
        self.thumbnailURL = thumbnailURL
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
