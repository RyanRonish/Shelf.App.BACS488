//
//  ManualBookEntryView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//
/*
import SwiftUI

struct ManualBookEntryView: View {
    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var selectedCollection = "My Books"
    let collections = ["My Books", "Favorites", "To Read"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Details")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("ISBN (Optional)", text: $isbn)
                }
                
                Section(header: Text("Add to Collection")) {
                    Picker("Collection", selection: $selectedCollection) {
                        ForEach(collections, id: \.self) { collection in
                            Text(collection)
                        }
                    }
                }
                
                Button(action: {
                    saveBook()
                }) {
                    Text("Save Book")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Add Book Manually")
        }
    }
    
    func saveBook() {
        // Logic to save book details (can integrate CoreData or Firebase)
        print("Book saved: \(title), \(author), \(isbn), Collection: \(selectedCollection)")
    }
}
#Preview {
    ManualBookEntryView()
}
*/
