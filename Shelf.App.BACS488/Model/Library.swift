//
//  Library.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 2/5/25.
//

import Foundation

class Library: ObservableObject {
    @Published var collections: [BookCollection] = []

    func removeCollection(_ collection: BookCollection) {
        collections.removeAll { $0.id == collection.id }
        save()
    }

    func showBookForm(for collection: BookCollection) {
        // Logic to present a sheet or new view for book entry
    }

    func scanBook(for collection: BookCollection) {
        // Invoke scanner functionality
    }

    func save() {
        // Save collections persistently (e.g., UserDefaults, CoreData, Firebase)
    }
}
