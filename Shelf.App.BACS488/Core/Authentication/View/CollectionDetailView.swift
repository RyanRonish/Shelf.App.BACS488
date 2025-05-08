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

    var body: some View {
        let booksInCollection = appViewModel.books(in: collection)

        VStack {
            if booksInCollection.isEmpty {
                Text("No books in this collection yet.")
                    .foregroundColor(.gray)
            } else {
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(0..<3, id: \.self) { rowIndex in
                        VStack(alignment: .leading, spacing: 12) {
                            //Text("Shelf \(rowIndex + 1)")
                                //.font(.title3.bold())
                                //.padding(.leading, 16)

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
            }
        }
        .onAppear {
            appViewModel.fetchBooks(for: collection)
        }
        .navigationTitle(collection.name)
        .toolbar {
            ToolbarControls(
                showDeleteConfirmation: $showDeleteConfirmation,
                showingScanner: $showingScanner,
                isShowingBookForm: $authViewModel.isShowingBookForm
            )
        }
        .alert("Delete Shelf?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteCollection()
                dismiss()
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

    private func getBooksForShelf(rowIndex: Int) -> [Book] {
        let allBooks = appViewModel.books(in: collection)
        let total = allBooks.count
        let chunkSize = Int(ceil(Double(total) / 3.0))
        let start = rowIndex * chunkSize
        let end = min(start + chunkSize, total)
        return Array(allBooks[start..<end])
    }
}

