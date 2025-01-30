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

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    @Published var collections: [BookCollection] = []  // ✅ Stores user collections
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
        Task { await fetchUserCollections() }
        
    }
    
    
    func fetchUserCollections() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let snapshot = try? await Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("collections")
            .getDocuments()
        
        if let documents = snapshot?.documents {
            self.collections = documents.compactMap { try? $0.data(as: BookCollection.self) }
        }
        print("DEBUG: Collections fetched for user \(uid)")
    }
    
    func addCollection(name: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let newCollection = BookCollection(name: name, books: [])
        let collectionRef = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("collections")
            .document()
        
        do {
            try await collectionRef.setData(from: newCollection)
            await fetchUserCollections()  // ✅ Refresh list after adding
        } catch {
            print("DEBUG: Failed to add collection: \(error.localizedDescription)")
        }
    }
    
    
    
    
    func signIn(withEmail email: String, password: String) async throws {
        do    {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            await fetchUserCollections()  // ✅ Fetch user's collections after login
            print("DEBUG: Logged in. Fetching collections for user \(result.user.uid)")
        } catch {
            print("DEBUG: Failed to log in with error \(error.localizedDescription)")
        }
        
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
            await fetchUserCollections()  // ✅ Fetch empty collections when a new user is created
            print("DEBUG: Created user \(fullname) and fetching collections")
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
        
    }
    // should take us to the login screen and sign out of firebase access
    func signOut() {
        do {
            try Auth.auth().signOut() // signs out user on backend
            self.userSession = nil // ends user session and returns the user to the login screen
            self.currentUser = nil // releases the user information (data model) this way it ensures when you login it logs into your profile
            self.collections = []  // ✅ Clears from memory but still exists in Firestore
            print("DEBUG: User signed out, collections reset locally but remain in Firestore")
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
        
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
        print("DEBUG: Current user is \(self.currentUser)")
    }
    
}

