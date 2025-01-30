//
//  Book.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import Foundation
import FirebaseFirestore

struct Book: Identifiable, Decodable {
    var id = UUID().uuidString
    let title: String
    let author: String
    let isbn: String
    let thumbnailURL: String?
}
