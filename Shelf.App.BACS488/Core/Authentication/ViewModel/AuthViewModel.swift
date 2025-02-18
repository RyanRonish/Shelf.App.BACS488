//
//  AuthViewModel.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/29/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI


protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}


@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var collections: [BookCollection] = []  // ✅ Stores user collections
    @Published var selectedCollection: BookCollection? // ✅ Stores the selected collection for book form
    @Published var isShowingBookForm: Bool = false    // ✅ Controls UI state for book form

    init() {
        self.userSession = Auth.auth().currentUser

        Task {
            await fetchUser()
            await fetchUserCollections()
        }
    }

    // Fetch user data from Firestore
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: NO user ID found.")
            return
        }

        let userRef = Firestore.firestore().collection("users").document(uid)
        do {
            let document = try await userRef.getDocument()
            if let data = document.data() {
                // ✅ Fix: Convert Firestore array into Book objects safely
                var favoriteBooks: [Book] = []
                if let booksArray = data["favoriteBooks"] as? [[String: Any]] {
                               for bookData in booksArray {
                                   if let id = bookData["id"] as? String,
                                      let title = bookData["title"] as? String,
                                      let author = bookData["author"] as? String,
                                      let isbn = bookData["isbn"] as? String,
                                      let thumbnailURL = bookData["thumbnailURL"] as? String {
                                       let book = Book(id: id, title: title, author: author, isbn: isbn, thumbnailURL: thumbnailURL)
                                       favoriteBooks.append(book)
                                   }
                               }
                           }


                let user = User(
                    id: data["id"] as? String ?? UUID().uuidString,
                    fullname: data["fullname"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    avatarUrl: data["avatarUrl"] as? String,
                    bio: data["bio"] as? String,
                    favoriteBooks: favoriteBooks, // ✅ Now safely mapped
                    totalBooks: data["totalBooks"] as? Int ?? 0,
                    totalCollections: data["totalCollections"] as? Int ?? 0,
                    joinDate: Date(timeIntervalSince1970: data["joinDate"] as? TimeInterval ?? Date().timeIntervalSince1970),
                    isDarkModeEnabled: data["isDarkModeEnabled"] as? Bool ?? false
                )

                DispatchQueue.main.async {
                    self.currentUser = user
                }
            }
        } catch {
            print("DEBUG: Error fetching user - \(error.localizedDescription)")
        }
    }

    // Fetch user's collections from Firestore
    func fetchUserCollections() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No authenticated user found.")
            return
        }

        let snapshot = try? await Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("collections")
            .getDocuments()

        DispatchQueue.main.async {
            if let documents = snapshot?.documents {
                self.collections = documents.compactMap { doc in
                    var collection = try? doc.data(as: BookCollection.self)
                    collection?.id = doc.documentID // ✅ Manually assign the Firestore ID
                    return collection
                }
                print("DEBUG: Refreshed UI - Fetched \(self.collections.count) collections from Firestore")
            }
        }
    }

    // Add a new book collection
    func addCollection(name: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let newCollectionRef = db.collection("users")
            .document(uid)
            .collection("collections")
            .document()
        
        var newCollection = BookCollection(name: name)
        newCollection.id = newCollectionRef.documentID

        do {
            try await newCollectionRef.setData(from: newCollection)
            print("DEBUG: Collection successfully added with ID:", newCollection.id ?? "No ID")
            await fetchUserCollections()
        } catch {
            print("DEBUG: Failed to add collection: \(error.localizedDescription)")
        }
    }
    
    
    func deleteCollection(collection: BookCollection, deleteBooks: Bool) async {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("DEBUG: No authenticated user found.")
            return
        }
        
        guard let collectionID = collection.id else {
            print("DEBUG: Collection ID is missing.")
            return
        }

        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
            .document(userID)
            .collection("collections")
            .document(collectionID)

        do {
            if deleteBooks {
                // ✅ Delete all books inside the collection
                let booksRef = collectionRef.collection("books")
                let booksSnapshot = try await booksRef.getDocuments()
                for document in booksSnapshot.documents {
                    try await booksRef.document(document.documentID).delete()
                }
            }
            
            try await collectionRef.delete()
            print("DEBUG: Collection successfully deleted from Firestore")

            await fetchUserCollections()

        } catch {
            print("DEBUG: Error deleting collection: \(error.localizedDescription)")
        }
    }

    // Update user profile fields (e.g., bio, avatar, dark mode)
    func updateUserField(field: String, value: Any) async {
        guard let uid = currentUser?.id else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)

        do {
            try await userRef.updateData([field: value])
            DispatchQueue.main.async {
                switch field {
                case "bio":
                    self.currentUser?.bio = value as? String
                case "avatarUrl":
                    self.currentUser?.avatarUrl = value as? String
                case "isDarkModeEnabled":
                    self.currentUser?.isDarkModeEnabled = value as? Bool ?? false
                default:
                    break
                }
            }
        } catch {
            print("DEBUG: Error updating user data: \(error.localizedDescription)")
        }
    }

    // Upload Profile Picture to Firebase Storage
    func uploadProfilePicture(data: Data) async {
        guard let uid = currentUser?.id else { return }
        let storageRef = Storage.storage().reference().child("profile_pics/\(uid).jpg")

        do {
            let _ = try await storageRef.putDataAsync(data)
            let downloadUrl = try await storageRef.downloadURL()
            await updateUserField(field: "avatarUrl", value: downloadUrl.absoluteString)
        } catch {
            print("DEBUG: Failed to upload image: \(error.localizedDescription)")
        }
    }

    // Sign-in with email and password
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            await fetchUserCollections()
        } catch {
            print("DEBUG: Failed to log in: \(error.localizedDescription)")
        }
    }

    // Create a new user
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user

            let user = User(id: result.user.uid, fullname: fullname, email: email, avatarUrl: nil, bio: nil, favoriteBooks: [], totalBooks: 0, totalCollections: 0, joinDate: Date(), isDarkModeEnabled: false)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)

            await fetchUser()
            await fetchUserCollections()
        } catch {
            print("DEBUG: Failed to create user: \(error.localizedDescription)")
        }
    }

    // Sign out user
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            self.collections = []
        } catch {
            print("DEBUG: Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    func saveUserToFirestore(user: User) async {
        let userRef = Firestore.firestore().collection("users").document(user.id)

        let userData: [String: Any] = [
            "id": user.id,
            "fullname": user.fullname,
            "email": user.email,
            "avatarUrl": user.avatarUrl ?? "",
            "bio": user.bio ?? "",
            "favoriteBooks": user.favoriteBooks.map { ["id": $0.id, "title": $0.title, "author": $0.author, "isbn": $0.isbn, "thumbnailURL": $0.thumbnailURL] },
            "totalBooks": user.totalBooks,
            "totalCollections": user.totalCollections,
            "joinDate": (user.joinDate ?? Date()).timeIntervalSince1970,  // ✅ Convert Date to timestamp
            "isDarkModeEnabled": user.isDarkModeEnabled
        ]

        do {
            try await userRef.setData(userData)
            print("DEBUG: User successfully saved to Firestore!")
        } catch {
            print("DEBUG: Failed to save user - \(error.localizedDescription)")
        }
    }

    func showBookForm(for collection: BookCollection) {
        self.selectedCollection = collection
        self.isShowingBookForm = true
        print("DEBUG: Showing book form for collection:", collection.name)
    }
    
    func scanBook(for collection: BookCollection) {
        print("DEBUG: Scanning book for collection:", collection.name)
    }
    
    
    func addBookToCollection(collection: BookCollection, book: Book) async {
        guard let collectionId = collection.id else {
            print("DEBUG: Collection ID not found.")
            return
        }

        let db = Firestore.firestore()
        let bookRef = db.collection("users")
            .document(Auth.auth().currentUser?.uid ?? "")
            .collection("collections")
            .document(collectionId)
            .collection("books")
            .document() // Firestore auto-generates book ID

        var newBook = book
        newBook.id = bookRef.documentID // Assign Firestore ID

        do {
            try await bookRef.setData(from: newBook)
            print("DEBUG: Book successfully added to collection:", collection.name)

            // ✅ Update local UI state
            DispatchQueue.main.async {
                if let index = self.collections.firstIndex(where: { $0.id == collectionId }) {
                    self.collections[index].books.append(newBook)
                }
            }

        } catch {
            print("DEBUG: Failed to add book: \(error.localizedDescription)")
        }
    }
    
    
    func deleteBook(collection: BookCollection, book: Book) async {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("DEBUG: No authenticated user found.")
            return
        }
        
        guard let collectionID = collection.id, let bookID = book.id else {
            print("DEBUG: Collection ID or Book ID is missing.")
            return
        }

        let db = Firestore.firestore()
        let bookRef = db.collection("users")
            .document(userID)
            .collection("collections")
            .document(collectionID)
            .collection("books")
            .document(bookID)

        do {
            try await bookRef.delete()
            print("DEBUG: Book successfully deleted from Firestore:", book.title)

            // ✅ Remove from UI state
            DispatchQueue.main.async {
                if let collectionIndex = self.collections.firstIndex(where: { $0.id == collectionID }) {
                    self.collections[collectionIndex].books.removeAll { $0.id == bookID }
                }
            }

        } catch {
            print("DEBUG: Failed to delete book: \(error.localizedDescription)")
        }
    }
}
