//
//  Collection.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 3/7/25.
//

import Foundation

import FirebaseFirestore

struct Collection: Identifiable, Codable {
    @DocumentID var id: String? // Firestore auto-generates an ID
    var name: String
    var createdAt: Date
}
