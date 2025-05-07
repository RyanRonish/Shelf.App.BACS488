import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct AddBookView: View {
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Input Fields
    @State private var title: String = ""
    @State private var author: String = ""
    //@State private var collectionID: String = ""
    @State private var isbn: String = ""
    @State private var thumbnailURL: String?
    @State private var description: String = ""
    @State private var publisher: String = ""
    @State private var year: String = ""

    @State private var debounceTimer: Timer?

    let collectionID: String // passed from parent view

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Info")) {
                    TextField("Title", text: $title)
                        .onChange(of: title) { newValue in
                            debounceTimer?.invalidate()
                            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                fetchBookDetails(for: newValue)
                            }
                        }

                    TextField("Author", text: $author)
                    TextField("ISBN", text: $isbn)
                    TextField("Publisher", text: $publisher)
                    TextField("Year", text: $year)
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.4)))
                }

                if let urlString = thumbnailURL, let url = URL(string: urlString) {
                    Section(header: Text("Cover Preview")) {
                        HStack {
                            Spacer()
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120)
                            } placeholder: {
                                ProgressView()
                            }
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarTitle("Add Book", displayMode: .inline)
            .navigationBarItems(trailing: Button("Save") {
                saveBookToFirestore()
            })
        }
    }

    // MARK: - Autofill Book Info
    private func fetchBookDetails(for title: String) {
        guard !title.isEmpty else { return }
        BookAPI.searchBooks(byTitle: title) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let books):
                    if let first = books.first {
                        self.title = first.title
                        self.author = first.author
                        self.isbn = first.isbn ?? ""
                        self.thumbnailURL = first.thumbnailURL
                        self.description = first.description ?? ""
                        self.publisher = first.publisher ?? ""
                        self.year = first.year ?? ""
                    }
                case .failure(let error):
                    print("Failed to fetch book info: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Save to Firestore
    private func saveBookToFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let bookId = UUID().uuidString
        let docRef = db.collection("users")
            .document(uid)
            .collection("collections")
            .document(collectionID)
            .collection("books")
            .document(bookId)

        let bookData: [String: Any] = [
            "id": bookId,
            "title": title,
            "author": author,
            "collectionID": collectionID,
            "isbn": isbn,
            "thumbnailURL": thumbnailURL ?? "",
            "description": description,
            "publisher": publisher,
            "year": year
        ]

        docRef.setData(bookData) { error in
            if let error = error {
                print("❌ Error saving book: \(error.localizedDescription)")
            } else {
                print("✅ Book saved!")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
