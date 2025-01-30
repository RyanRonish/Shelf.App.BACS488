//
//  CollectionDetailView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import SwiftUI

struct CollectionDetailView: View {
    let collection: BookCollection

    var body: some View {
        VStack {
            Text(collection.name)
                .font(.largeTitle)
                .bold()
                .padding(.top)

            List(collection.books) { book in
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
        }
        .navigationTitle("Books in \(collection.name)")
    }
}

#Preview {
    CollectionDetailView(collection: BookCollection(
        name: "Favorites",
        books: [
            Book(title: "The Hobbit", author: "J.R.R. Tolkien"),
            Book(title: "1984", author: "George Orwell")
        ]
    ))
}
