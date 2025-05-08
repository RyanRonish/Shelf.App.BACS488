//
//  BookShelvesView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 5/7/25.
//

import SwiftUI

struct BookShelvesView: View {
    let books: [Book]
    let onTapBook: (Book) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            ForEach(0..<3, id: \.self) { rowIndex in
                VStack(alignment: .leading, spacing: 12) {
                    Text("Shelf \(rowIndex + 1)")
                        .font(.title3.bold())
                        .padding(.leading, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(getBooksForShelf(rowIndex: rowIndex), id: \.id) { book in
                                BookCard(book: book)
                                    .onTapGesture {
                                        onTapBook(book)
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
    }

    private func getBooksForShelf(rowIndex: Int) -> [Book] {
        let total = books.count
        let chunkSize = Int(ceil(Double(total) / 3.0))
        let start = rowIndex * chunkSize
        let end = min(start + chunkSize, total)
        return Array(books[start..<end])
    }
}
