//
//  BookCollection.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import Foundation
import FirebaseFirestore

struct BookCollection: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var books: [Book]
}

