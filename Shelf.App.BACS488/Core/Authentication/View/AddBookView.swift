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
                // Scan Button
                Section {
                    Button(action: {
                        authViewModel.isShowingScanner = true
                    }) {
                        HStack {
                            Image(systemName: "barcode.viewfinder")
                            Text("Scan ISBN")
                        }
                        .foregroundColor(.blue)
                    }
                }
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
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) { // ✅ Add another button if needed
                    Button("Save") {
                        //saveBook()
                    }
                }
            })
            
            .sheet(isPresented: $authViewModel.isShowingScanner) {
                ISBNScannerView(scannedBook: $authViewModel.scannedBook, authViewModel: authViewModel)
            }
            .onChange(of: authViewModel.scannedBook) { newBook in
                if let newBook {
                    title = newBook.title
                    author = newBook.author
                    isbn = newBook.isbn ?? ""
                    thumbnailURL = newBook.thumbnailURL ?? ""
                    
                    authViewModel.scannedBook = nil // Reset after setting fields
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
                id: UUID().uuidString, // ✅ Generate a unique ID
                title: title,
                author: author,
                isbn: isbn.isEmpty ? nil : isbn,
                thumbnailURL: thumbnailURL.isEmpty ? nil : thumbnailURL
            )
            
            Task {
                await authViewModel.addBookToCollection(collection: collection, book: newBook)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    
    #Preview {
        AddBookView()
    }
    

