//
//  CollectionDetailView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

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
        guard let userID = Auth.auth().currentUser?.uid else {
            print("DEBUG: No authenticated user found.")
            return
        }
        
        guard let collectionID = collection.id else {
            print("DEBUG: Collection ID is missing.")
            return
        }

        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
            .document(userID)
            .collection("collections")
            .document(collectionID)

        collectionRef.delete { error in
            if let error = error {
                print("Error deleting collection: \(error.localizedDescription)")
            } else {
                print("Collection successfully deleted from Firestore")
                DispatchQueue.main.async {
                    // Remove from local app state
                    if let index = library.collections.firstIndex(where: { $0.id == collectionID }) {
                        library.collections.remove(at: index)
                    }

                    presentationMode.wrappedValue.dismiss() // Navigate back
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
