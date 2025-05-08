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
    @State private var selectedBook: Book?
    @State private var showBookDetail = false
    
    @State private var selectedCollection: BookCollection?
    
    @Environment(\.dismiss) private var dismiss
    
    // States for alert and Fire Animation
    @State private var showDeleteConfirmation = false
    @State private var showFireAnimation = false
    
    let collection: BookCollection
    var body: some View {
            VStack {
                if appViewModel.books(in: collection).isEmpty {
                    Text("No books in this collection yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(appViewModel.books(in: collection)) { book in
                                VStack {
                                    if let url = URL(string: book.thumbnailURL ?? "") {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 100, height: 150)
                                        .cornerRadius(8)
                                    }
                                    Text(book.title)
                                        .font(.caption)
                                        .frame(width: 100)
                                        .lineLimit(1)
                                }
                                .onTapGesture {
                                    selectedBook = book
                                    showBookDetail = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle(collection.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Collection", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingScanner = true
                    } label: {
                        Label("Scan Book", systemImage: "text.viewfinder")
                    }

                    Button {
                        authViewModel.isShowingBookForm = true
                    } label: {
                        Label("Add Book", systemImage: "plus")
                    }
                }
            }
            .alert("Delete Shelf?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    handleDeleteWithFire()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete this shelf and all books inside. Are you sure?")
            }
            .sheet(isPresented: $showBookDetail) {
                if let book = selectedBook {
                    BookDetailView(collection: collection, book: book)
                }
            }
            .sheet(isPresented: $authViewModel.isShowingBookForm) {
                AddBookView(collectionID: collection.id ?? "")
            }
            .sheet(isPresented: $showingScanner) {
                ISBNScannerView(scannedBook: $scannedBook)
            }
            .onChange(of: appViewModel.recognizedItems) { newItems in
                processRecognizedItems(newItems)
            }

            if showFireAnimation {
                FireEmojiAnimationView()
                    .transition(.opacity)
            }
        }

        private func processRecognizedItems(_ newItems: [RecognizedItem]) {
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

        private func handleDeleteWithFire() {
            withAnimation { showFireAnimation = true }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                deleteCollection()
                showFireAnimation = false
                dismiss()
            }
        }

        private func deleteCollection() {
            guard let user = Auth.auth().currentUser, let id = collection.id else { return }

            Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .collection("collections")
                .document(id)
                .delete { error in
                    if let error = error {
                        print("❌ Failed to delete collection: \(error.localizedDescription)")
                    } else {
                        print("✅ Collection deleted")
                        if let index = authViewModel.collections.firstIndex(where: { $0.id == id }) {
                            authViewModel.collections.remove(at: index)
                        }
                    }
                }
        }
    }

    // MARK: - Fire emoji animation
    struct FireEmojiAnimationView: View {
        let fireEmojis = Array(repeating: "🔥", count: 25) // repeat fire emoji 25 times
        
        var body: some View {
            ZStack {
                ForEach(0..<fireEmojis.count, id: \.self) { index in
                    Text(fireEmojis[index])
                        .font(.system(size: 40))
                        .position(
                            x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                            y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 200)
                        )
                        .opacity(0.7)
                        .transition(.scale)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 1.5...2.5))
                                .repeatForever(autoreverses: true),
                            value: UUID()
                        )
                }
            }
        }
    }
    
    
    struct FireEmojiView: View {
        @State private var yOffset: CGFloat = 0
        @State private var xOffset: CGFloat = 0
        @State private var opacity: Double = 1.0
        
        var body: some View {
            Text("🔥")
                .font(.system(size: 40))
                .opacity(opacity)
                .offset(x: xOffset, y: yOffset)
                .onAppear {
                    withAnimation(.easeOut(duration: 2.5)) {
                        yOffset = -300
                        xOffset = CGFloat.random(in: -100...100)
                        opacity = 0
                }
            }
        }
    }

struct BookCard: View {
    let book: Book

    var body: some View {
        VStack {
            if let url = URL(string: book.thumbnailURL ?? "") {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 150)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                }
            }

            Text(book.title)
                .font(.caption)
                .frame(width: 100)
                .lineLimit(1)
        }
        .padding(.vertical)
    }
}
