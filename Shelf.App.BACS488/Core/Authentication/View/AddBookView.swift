//
//  AddBookView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import SwiftUI

struct AddBookView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showScanner = false
    @State private var showManualEntry = false
    @State private var scannedBook: Book?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add a Book to Your Collection")
                .font(.title2)
                .bold()
                .padding()
            
            // 📌 Scan Book Button
            Button(action: {
                showScanner = true
            }) {
                Label("Scan Book Barcode", systemImage: "barcode.viewfinder")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // 📌 Add Sample Book to Collection (Testing)
            Button(action: {
                Task.init {
                    let newBook = Book(
                        title: "Sample Book",
                        author: "Author Name",
                        isbn: "123456789",
                        thumbnailURL: "https://example.com/book.jpg"
                    )
                    guard let collectionID = viewModel.collections.first?.id else {
                        print("DEBUG: No collection found to add the book.")
                        return
                    }
                    print("DEBUG: Adding book to collection: \(collectionID)")
                    await viewModel.addBookToCollection(collectionId: collectionID, book: newBook)
                }
            }) {
                Text("Add Sample Book to Collection")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            // 📌 Manual Book Entry Button
            Button(action: {
                showManualEntry = true
            }) {
                Label("Enter Book Manually", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // 📌 Display Scanned Book Details
            if let book = scannedBook {
                VStack {
                    Text("Scanned Book Details")
                        .font(.headline)
                        .padding(.top)
                    
                    if let url = URL(string: book.thumbnailURL) {
                        AsyncImage(url: url)
                            .frame(width: 100, height: 150)
                            .cornerRadius(10)
                    }
                    
                    Text("Title: \(book.title)")
                        .font(.subheadline)
                        .bold()
                    Text("Author: \(book.author)")
                        .font(.subheadline)
                    Text("ISBN: \(book.isbn)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
        .padding()
        .sheet(isPresented: $showScanner) {
            ISBNScannerView(scannedBook: $scannedBook)
        }
        .sheet(isPresented: $showManualEntry) {
            ManualBookEntryView()
                .environmentObject(viewModel)  // ✅ Pass AuthViewModel to ManualBookEntryView
        }
    }
}

#Preview {
    AddBookView()
}


