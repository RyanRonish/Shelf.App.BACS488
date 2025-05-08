//
//  User.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/29/25.
//

import Foundation
import FirebaseFirestore


struct User: Identifiable, Codable {
    var id: String // Firestore automatically assigns an ID
    let fullname: String
    let email: String
    var avatarUrl: String? = nil  // Profile Picture URL
    var bio: String? = nil        // User Bio
    var favoriteBooks: [Book] = [] // List of favorite books
    var totalBooks: Int = 0        // Total books added
    var totalCollections: Int = 0  // Total collections created
    @ServerTimestamp var joinDate: Date? // Automatically set when stored
    var isDarkModeEnabled: Bool = false // Dark mode preference

    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
    //  Custom CodingKeys to store joinDate as a timestamp
    enum CodingKeys: String, CodingKey {
        case id, fullname, email, avatarUrl, bio, favoriteBooks, totalBooks, totalCollections, joinDate, isDarkModeEnabled
    }
}


/*struct Book: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let coverImage: String // URL of the book cover
}
*/
/*
//
extension User {
    static var MOCK_USER = User(
        id: "123456",
        fullname: "Kevin Durant",
        email: "test@gmail.com",
        avatarUrl: nil,
        bio: "Basketball legend and book lover!",
        favoriteBooks: [
            Book(id: "1", title: "The Alchemist", coverImage: "https://example.com/alchemist.jpg"),
            Book(id: "2", title: "Atomic Habits", coverImage: "https://example.com/atomic_habits.jpg")
        ],
        totalBooks: 12,
        totalCollections: 3,
        joinDate: Date(),
        isDarkModeEnabled: false
    )
}
*/
