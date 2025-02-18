//
//  AddBookView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import SwiftUI

struct AddBookView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var isbn: String = ""
    @State private var thumbnailURL: String = ""

    var body: some View {
        NavigationView {
            Form {
                // 📌 Book Details
                Section(header: Text("Book Details")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("ISBN (Optional)", text: $isbn)
                    TextField("Thumbnail URL (Optional)", text: $thumbnailURL)
                }
                
                // 📌 Save Button
                Section {
                    Button(action: addBook) {
                        HStack {
                            Spacer()
                            Text("Add Book")
                                .bold()
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty || author.isEmpty)
                }
            }
            .navigationTitle("Add Book")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    // 📌 Function to Add the Book
    private func addBook() {

        guard let collection = authViewModel.selectedCollection else {
            print("DEBUG: No collection selected.")
            return
        }

        let newBook = Book(
            title: title,
            author: author,
            isbn: isbn.isEmpty ? nil : isbn,
            thumbnailURL: thumbnailURL.isEmpty ? nil : thumbnailURL
        )

        Task {
            await authViewModel.addBookToCollection(collectionId: collection.id ?? "", book: newBook)
            print("DEBUG: Book added manually to collection \(collection.name)")
            presentationMode.wrappedValue.dismiss()
        }
    }
}


#Preview {
    AddBookView()
}


