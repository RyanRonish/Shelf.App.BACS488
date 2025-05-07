//
//  BookDetailView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 5/7/25.
//

import SwiftUI

struct BookDetailView: View {
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
    }
}
