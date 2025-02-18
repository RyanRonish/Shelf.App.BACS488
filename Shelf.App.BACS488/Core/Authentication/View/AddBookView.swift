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
    @State private var selectedCollectionId: String?

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
                
                // 📌 Collection Selection (if no collection is pre-selected)
                if authViewModel.selectedCollection == nil {
                    Section(header: Text("Select Collection")) {
                        if authViewModel.collections.isEmpty {
                            Text("No collections available. Please create one first.")
                                .foregroundColor(.gray)
                        } else {
                            Picker("Collection", selection: $selectedCollectionId) {
                                ForEach(authViewModel.collections, id: \.id) { collection in
                                    Text(collection.name).tag(collection.id)
                                }
                            }
                        }
                    }
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
                    .disabled(title.isEmpty || author.isEmpty || (selectedCollectionId == nil && authViewModel.selectedCollection == nil))
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
        .onAppear {
            if selectedCollectionId == nil, let firstCollection = authViewModel.collections.first {
                selectedCollectionId = firstCollection.id
            }
        }
    }

    // 📌 Function to Add the Book
    private func addBook() {
        let collectionId = authViewModel.selectedCollection?.id ?? selectedCollectionId

        guard let collectionId = collectionId else {
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
            await authViewModel.addBookToCollection(collectionId: collectionId, book: newBook)
            print("DEBUG: Book added manually to collection \(collectionId)")
            presentationMode.wrappedValue.dismiss()
        }
    }
}


#Preview {
    AddBookView()
}


