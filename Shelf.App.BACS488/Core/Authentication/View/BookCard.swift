//
//  BookCard.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 5/7/25.
//

import SwiftUI

struct BookCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = URL(string: book.thumbnailURL ?? "") {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 160)
                        .clipped()
                        .cornerRadius(10)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 160)
                        .cornerRadius(10)
                }
            }

            Text(book.title)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)

            Text(book.author)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(width: 120)
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
