import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import VisionKit

struct CollectionDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var appViewModel: AppViewModel

    @State private var scannedBook: Book? = nil
    @State private var showingScanner = false
    @State private var selectedBook: Book? = nil
    @State private var showBookDetail = false
    @State private var showDeleteConfirmation = false
    @State private var showFireAnimation = false

    let collection: BookCollection

    @Environment(\.dismiss) private var dismiss
    
    enum RecognizedItem: Equatable {
        case text(String)
        case barcode(String)
    }

    var body: some View {
        
        let booksInCollection = appViewModel.books(in: collection)
        print("🟡 Books in collection \(collection.id ?? "nil"):", booksInCollection.map { $0.title })
        
        VStack {
            if appViewModel.books(in: collection).isEmpty {
                Text("No books in this collection yet.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
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
                                                selectedBook = book
                                                showBookDetail = true
                                            }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                
        .onAppear {
            appViewModel.fetchBooks(for: collection)
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
        .sheet(isPresented: $authViewModel.isShowingBookForm) {
            AddBookView(collectionID: collection.id ?? "")
        }
        .sheet(isPresented: $showingScanner) {
            ISBNScannerView(scannedBook: $scannedBook)
        }
        .onReceive(appViewModel.$recognizedItems) { newItems in
            processRecognizedItems(newItems as [RecognizedItem])
        }

        if showFireAnimation {
            FireEmojiAnimationView()
                .transition(.opacity)
        }
    }

    // MARK: - Helpers

    private func getBooksForShelf(rowIndex: Int) -> [Book] {
        let allBooks = appViewModel.books(in: collection)
        let total = allBooks.count
        let chunkSize = Int(ceil(Double(total) / 3.0))
        let start = rowIndex * chunkSize
        let end = min(start + chunkSize, total)
        return Array(allBooks[start..<end])
    }

    private func processRecognizedItems(_ newItems: [RecognizedItem]) {
        guard let firstItem = newItems.first else { return }
        guard case let .text(rawText) = firstItem else { return }

        let scannedTitle = rawText.trimmingCharacters(in: .whitespacesAndNewlines)

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
        withAnimation {
            showFireAnimation = true
        }

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
                    print("✅ Successfully deleted collection")
                    if let index = authViewModel.collections.firstIndex(where: { $0.id == id }) {
                        authViewModel.collections.remove(at: index)
                    }
                }
            }
    }
    
    struct FireEmojiAnimationView: View {
        let fireEmojis = Array(repeating: "🔥", count: 25)

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
}
