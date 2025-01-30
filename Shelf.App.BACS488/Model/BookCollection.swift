//
//  BookCollection.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import Foundation
import FirebaseFirestore

struct BookCollection: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    var books: [Book] = []
}
