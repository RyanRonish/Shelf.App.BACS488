//
//  CollectionDetailView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import SwiftUI
import FirebaseFirestore

struct CollectionDetailView: View {
    @ObservedObject var collection: BookCollection  // Now works because BookCollection is ObservableObject
    @EnvironmentObject var library: Library
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text(collection.name)
                .font(.largeTitle)
                .bold()
                .padding(.top)

            List {
                ForEach(collection.books) { book in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.headline)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                }
                .onDelete(perform: deleteBook)
            }
            .listStyle(InsetGroupedListStyle())

            Spacer()

            HStack {
                Button(action: addBookManually) {
                    Label("Add Book", systemImage: "plus")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }

                Button(action: scanBook) {
                    Label("Scan Book", systemImage: "barcode.viewfinder")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
        }
        .navigationTitle("Books in \(collection.name)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive, action: deleteCollection) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    // MARK: - Delete Collection
    //private func deleteCollection() {
        //library.removeCollection(collection)
        //presentationMode.wrappedValue.dismiss()
    //}

    private func deleteCollection() {
        guard let collectionID = collection.id else { return } // Ensure collection has an ID

        let db = Firestore.firestore()
        db.collection("collections").document(collectionID).delete { error in
            if let error = error {
                print("Error deleting collection: \(error.localizedDescription)")
            } else {
                print("Collection successfully deleted from Firestore")
                DispatchQueue.main.async {
                    library.removeCollection(collection) // Remove from local state
                    presentationMode.wrappedValue.dismiss() // Return to home screen
                }
            }
        }
    }

    // MARK: - Delete Book
    private func deleteBook(at offsets: IndexSet) {
        collection.books.remove(atOffsets: offsets)
        library.save()
    }

    // MARK: - Add Book Manually
    private func addBookManually() {
        library.showBookForm(for: collection)
    }

    // MARK: - Scan Book
    private func scanBook() {
        library.scanBook(for: collection)
    }
}

#Preview {
    CollectionDetailView(collection: BookCollection(
        name: "Favorites",
        books: [
            Book(title: "The Hobbit", author: "J.R.R. Tolkien", isbn: "isbn", thumbnailURL: "https://example.com/default-thumbnail.jpg"),
            Book(title: "1984", author: "George Orwell", isbn: "isbn", thumbnailURL: "https://example.com/default-thumbnail.jpg")
        ]
    ))
}
