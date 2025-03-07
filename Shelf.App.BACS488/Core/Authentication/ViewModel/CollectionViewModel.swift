//
//  CollectionViewModel.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 3/7/25.
//

import Foundation

import FirebaseFirestore
import FirebaseAuth

class CollectionViewModel: ObservableObject {
    @Published var collections: [Collection] = [] // Store fetched collections
    private let db = Firestore.firestore()
    
    // Function to add a collection under the current user's document
    func addCollection(collectionName: String, completion: @escaping (Bool, String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, "User not authenticated.")
            return
        }
        
        let collectionData: [String: Any] = [
            "name": collectionName,
            "createdAt": Timestamp()
        ]
        
        db.collection("users").document(userId)
            .collection("collections").addDocument(data: collectionData) { error in
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
    }
    
    func fetchCollections() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }

        db.collection("users").document(userId)
            .collection("collections").order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching collections: \(error.localizedDescription)")
                    return
                }

                self.collections = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Collection.self)
                } ?? []
            }
    }
}
