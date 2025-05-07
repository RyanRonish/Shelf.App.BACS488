//
//  BookDetailView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 5/7/25.
//

import SwiftUI
import Firebase
import FirebaseAuth


struct BookDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    var collection: BookCollection
    
    let book: Book

    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let urlString = book.thumbnailURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                }
                
                Text(book.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("by \(book.author)")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                if let description = book.description {
                    Text(description)
                        .font(.body)
                        .padding(.top)
                }
                
                Group {
                    if let publisher = book.publisher {
                        Text("Publisher: \(publisher)")
                    }
                    
                    if let year = book.year {
                        Text("Year: \(year)")
                    }
                    
                    if let isbn = book.isbn {
                        Text("ISBN: \(isbn)")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 4)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    deleteBook()
                } label: {
                    Label("Delete Book", systemImage: "trash")
                }
            }
        }
    }
    func deleteBook() {
        guard let user = Auth.auth().currentUser else { return }
        guard let collectionId = collection.id, let bookId = book.id else { return }

            let db = Firestore.firestore()
            db.collection("users")
                .document(user.uid)
                .collection("collections")
                .document(collectionId)
                .collection("books")
                .document(bookId)
                .delete { error in
                    if let error = error {
                        print("DEBUG: Failed to delete book - \(error.localizedDescription)")
                    } else {
                        print("DEBUG: Book deleted successfully")
                        dismiss()
                }
            }
        }
    }
