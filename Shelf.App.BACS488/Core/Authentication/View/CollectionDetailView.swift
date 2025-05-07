//
//  CollectionDetailView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import VisionKit


struct RecognizedItemWrapper: Identifiable {
    let id = UUID()
    let item: RecognizedItem
}

enum RecognizedItem: Equatable {
    case text(String)
    case barcode(String)
}

struct CollectionDetailView: View {
    //@ObservedObject var collection: BookCollection
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var appViewModel: AppViewModel
    @State var scannedBook: Book? = nil
    @State private var showingScanner = false
    @State private var recognizedText = ""
    
    let collection: BookCollection

    var body: some View {
        VStack {
            if appViewModel.books(in: collection).isEmpty {
                Text("No books in this collection.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(appViewModel.books(in: collection)) { book in
                    HStack(alignment: .top) {
                        if let urlString = book.thumbnailURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 75)
                                    .cornerRadius(6)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.headline)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if let year = book.year {
                                Text(year).font(.caption).foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(collection.name)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    showingScanner = true
                }) {
                    Label("Scan Book", systemImage: "text.viewfinder")
                }
                Button(action: {
                    authViewModel.isShowingBookForm = true
                }) {
                    Label("Add Book", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $authViewModel.isShowingBookForm) {
            AddBookView(collectionID: collection.id ?? "")
                .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showingScanner) {
            ISBNScannerView(scannedBook: $scannedBook)
        }
        .onChange(of: appViewModel.recognizedItems) { newItems in
            processRecognizedItems(newItems)
        }
    }

    // MARK: - Process Scanned Text into Book
    func processRecognizedItems(_ newItems: [RecognizedItem]) {
        guard let firstItem = newItems.first else { return }

        guard case let .text(scannedTitleRaw) = firstItem else { return }
        let scannedTitle = scannedTitleRaw.trimmingCharacters(in: .whitespacesAndNewlines)

        BookAPI.searchBooks(byTitle: scannedTitle) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let books):
                    if let first = books.first {
                        let book = Book(
                            id: UUID().uuidString,
                            title: first.title,
                            author: first.author,
                            collectionID: collection.id ?? UUID().uuidString,
                            isbn: first.isbn,
                            thumbnailURL: first.thumbnailURL,
                            description: first.description,
                            publisher: first.publisher,
                            year: first.year
                        )

                        Task {
                            await authViewModel.addBookToCollection(collection: collection, book: book)
                        }
                    }
                case .failure(let error):
                    print("❌ Failed to fetch book from scanned title: \(error.localizedDescription)")
                }
            }
        }
    }
}

