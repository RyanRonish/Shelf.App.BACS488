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
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showDeleteAlert = false  // ✅ Controls delete confirmation alert
    @State private var deleteBooks = false      // ✅ Stores user choice for deleting books
    
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
                .onDelete { indexSet in
                    for index in indexSet {
                        let book = collection.books[index]
                        Task {
                            await authViewModel.deleteBook(collection: collection, book: book)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            Spacer()
            
            HStack {
                Button(action: {
                    authViewModel.selectedCollection = collection // ✅ Ensure the correct collection is selected
                    authViewModel.isShowingBookForm = true        // ✅ Trigger form display
                }) {
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
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .alert("Delete Collection", isPresented: $showDeleteAlert) {
            Button("Delete Collection & Books", role: .destructive) {
                deleteBooks = true
                Task {
                    await authViewModel.deleteCollection(collection: collection, deleteBooks: deleteBooks)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            Button("Delete Collection Only", role: .destructive) {
                deleteBooks = false
                Task {
                    await authViewModel.deleteCollection(collection: collection, deleteBooks: deleteBooks)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Do you want to delete the books inside this collection as well?")
        }
        
        .sheet(isPresented: $authViewModel.isShowingBookForm) {
            AddBookView().environmentObject(authViewModel) // ✅ Displays Add Book Form
        }
        
        .onChange(of: authViewModel.scannedBook) { newBook in
            if let book = newBook {
                Task {
                    await authViewModel.addBookToCollection(collection: collection, book: book)
                    authViewModel.scannedBook = nil // ✅ Reset after adding
                }
            }
        }
        
    }
    
     // MARK: - Add Book Manually
     private func addBookManually() {
         authViewModel.showBookForm(for: collection)
     }
     
     // MARK: - Scan Book
    //scan button functionality
    private func scanBook() {
        authViewModel.selectedCollection = collection // ✅ Ensure the correct collection is selected
        authViewModel.isShowingScanner = true        // ✅ Trigger the scanner
    }
}

    

    #Preview {
        CollectionDetailView(collection: BookCollection(
            name: "Favorites",
            ownerId: "testUser123",
            books: [
                Book(title: "The Hobbit", author: "J.R.R. Tolkien", isbn: "isbn", thumbnailURL: "https://example.com/default-thumbnail.jpg"),
                Book(title: "1984", author: "George Orwell", isbn: "isbn", thumbnailURL: "https://example.com/default-thumbnail.jpg")
            ]
        ))
    }

