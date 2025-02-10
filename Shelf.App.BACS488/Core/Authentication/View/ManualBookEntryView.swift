//
//  ManualBookEntryView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import SwiftUI

struct ManualBookEntryView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss  // ✅ Allows dismissal
    
    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var selectedCollection: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Details")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("ISBN (Optional)", text: $isbn)
                }
                
                // 📌 Collection Picker - Dynamically Fetch User's Collections
                Section(header: Text("Add to Collection")) {
                    if viewModel.collections.isEmpty {
                        Text("No collections available. Please create one first.")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Select Collection", selection: $selectedCollection) {
                            ForEach(viewModel.collections, id: \.id) { collection in
                                Text(collection.name).tag(collection.id)
                            }
                        }
                    }
                }
                
                // 📌 Save Button
                Button(action: {
                    saveBook()
                }) {
                    Text("Save Book")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.collections.isEmpty ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.collections.isEmpty || title.isEmpty || author.isEmpty)
            }
            .navigationTitle("Add Book Manually")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            if selectedCollection == nil, let firstCollection = viewModel.collections.first {
                selectedCollection = firstCollection.id
            }
        }
    }
    
    // 📌 Function to Save the Book
    func saveBook() {
        guard let collectionId = selectedCollection else {
            print("DEBUG: No collection selected.")
            return
        }

        let newBook = Book(
            title: title,
            author: author,
            isbn: isbn,
            thumbnailURL: "https://example.com/default-book-cover.jpg"
        )

        Task {
            await viewModel.addBookToCollection(collectionId: collectionId, book: newBook)
            print("DEBUG: Book added manually to \(collectionId)")
            dismiss()
        }
    }
}


#Preview {
    ManualBookEntryView()
}

