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
                        Rectangle().fill(Color.gray.opacity(0.3))
                    }
                } else {
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
            }
            .frame(width: 120, height: 160)
            .clipped()
            .cornerRadius(10)

            // Title and author are now part of the rectangle area
            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.caption)
                    .bold()
                    .lineLimit(1)

                Text(book.author)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding([.horizontal, .bottom], 6)
        }
        .frame(width: 120)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)

        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    deleteBook()
                } label: {
                    Label("Delete Book", systemImage: "trash")
                }
            }
        }
                
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

private func deleteBook() {
    guard let user = Auth.auth().currentUser,
          let collectionId = collection.id,
          let bookId = book.id else { return }
    
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
