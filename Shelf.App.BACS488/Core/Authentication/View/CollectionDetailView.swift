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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if appViewModel.books(in: collection).isEmpty {
                    Text("No books in this collection yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach([0, 1, 2], id: \.self) { shelfIndex in
                        VStack(alignment: .leading) {
                            Text("Shelf \(shelfIndex + 1)")
                                .font(.headline)
                                .padding(.leading)

                            let booksOnShelf = getBooksForShelf(shelf: shelfIndex)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(booksOnShelf, id: \.id) { book in
                                        BookCard(book: book)
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
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete this shelf and all books inside. Are you sure?")
        }
        .sheet(isPresented: $showBookDetail) {
            if let book = selectedBook {
                BookDetailView(collection: collection, book: book)
            }
        }
        
        if showFireAnimation {
            FireEmojiAnimationView()
                .transition(.opacity)
        }
    }
    
    func getBooksForShelf(shelf: Int) -> [Book] {
        let allBooks = appViewModel.books(in: collection)
        let countPerShelf = max(allBooks.count / 3, 1)
        let start = shelf * countPerShelf
        let end = min(start + countPerShelf, allBooks.count)
        return Array(allBooks[start..<end])
    }
    
    func ZStack() {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(appViewModel.books(in: collection)) { book in
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.headline)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 3)
                        .frame(width: 150, height:100)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .onTapGesture {
                            selectedBook = book
                            showBookDetail = true
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(appViewModel.books(in: collection)) { book in
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.headline)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.3))
                            .frame(width: 120, height: 60)
                            .onTapGesture {
                                selectedBook = book
                                showBookDetail = true
                            }
                    }
                }
                .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(appViewModel.books(in: collection)) { book in
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.headline)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 120, height: 60)
                            .onTapGesture {
                                selectedBook = book
                                showBookDetail = true
                            }
                    }
                }
                .padding(.horizontal)
            }
            .sheet(isPresented: $showBookDetail) {
                if let selectedBook = selectedBook {
                    BookDetailView(collection: selectedCollection!, book: selectedBook)
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
            // emoji fire animation
            .overlay {
                if showFireAnimation {
                    FireEmojiView()
                        .transition(.opacity)
                }
            }
            if showFireAnimation {
                SwiftUICore.ZStack {
                    ForEach(0..<25, id: \.self) { index in
                        FireEmojiAnimationView()
                    }
                }
                .transition(.opacity)
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
    
    func deleteCollection() {
        guard let user = Auth.auth().currentUser else { return }
        guard let id = collection.id else { return }
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(user.uid)
            .collection("collections")
            .document(id)
            .delete { error in
                if let error = error {
                    print("DEBUG: Failed to delete collection - \(error.localizedDescription)")
                } else {
                    print("DEBUG: Successfully deleted collection")
                    if let index = authViewModel.collections.firstIndex(where: { $0.id == id }) {
                        authViewModel.collections.remove(at: index)
                    }
                }
            }
    }
    
    private func handleDeleteWithFire() {
        withAnimation {
            showFireAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            deleteCollection()
            showFireAnimation = false
            dismiss() // Use @Environment(\.dismiss)
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
