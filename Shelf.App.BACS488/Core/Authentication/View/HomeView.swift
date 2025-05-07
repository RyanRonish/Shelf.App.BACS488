//
//  HomeView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showAddCollectionSheet = false
    @State private var newCollectionName = ""
    @State private var showScanner = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Title
                Text("My Shelfs")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                // Display User's Collections
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(authViewModel.collections) { collection in
                            NavigationLink(destination: CollectionDetailView(collection: collection)
                                .environmentObject(appViewModel) // ✅ Pass appViewModel
                            ) {
                                CollectionCard(collection: collection)
                            }
                        }
                    }
                    .padding()
                }
                // 📌 Add Collection & Scan Buttons
                HStack(spacing: 20) {
                    // ✅ Add Collection Button
                    Button(action: { showAddCollectionSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Shelf")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(width: 150, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    // ✅ Scan Book Button
                    Button(action: {
                        appViewModel.scanType = .bookCover //book cover scanning
                        showScanner = true })
                    {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                            Text("Scan Book")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(width: 150, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: profileButton) // ✅ Profile Button
            .sheet(isPresented: $showAddCollectionSheet) {
                addCollectionSheet
            }
            .sheet(isPresented: $showScanner) {
                // ✅ Open Scanner when the button is clicked
                ISBNScannerView(scannedBook: $appViewModel.scannedBook)
                    .environmentObject(authViewModel)
                    .onAppear {
                        // ✅ Automatically process scanned book
                        if let book = appViewModel.scannedBook {
                            addScannedBook(book)
                            appViewModel.scannedBook = nil // ✅ Reset after adding
                        }
                    }
            }
        }
    }
    
    // 📌 Function to Save Scanned Book to Firestore
    private func addScannedBook(_ book: Book) {
        guard let collection = authViewModel.selectedCollection else {
            print("DEBUG: No collection selected.")
            return
        }

        Task {
            await authViewModel.addBookToCollection(collection: collection, book: book)
        }
    }
    
    // Profile button in the navigation bar
    private var profileButton: some View {
        NavigationLink(destination: ProfileView()) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
        }
    }
    // Sheet for adding a new collection
    private var addCollectionSheet: some View {
        VStack {
            Text("New Collection")
                .font(.title2)
                .bold()
                .padding()
            TextField("Collection Name", text: $newCollectionName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Save") {
                Task {
                    await authViewModel.addCollection(name: newCollectionName)
                    newCollectionName = ""
                    showAddCollectionSheet = false
                }
            }
            .disabled(newCollectionName.isEmpty)
            .frame(width: 200, height: 50)
            .background(newCollectionName.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
        }
        .padding()
    }
}
// MARK: - Collection Card View
struct CollectionCard: View {
    let collection: BookCollection
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green.opacity(0.3))
                .frame(height: 150)
                .overlay(
                    Text(collection.name)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                )
            
            Text("\(collection.books.count) books")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(width: 150)
    }
}

#Preview {
    HomeView()
}
