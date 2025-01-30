//
//  HomeView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showAddCollectionSheet = false
    @State private var newCollectionName = ""
    var body: some View {
        NavigationView {
            VStack {
                // Title
                Text("My Book Collections")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                // Display User's Collections
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(viewModel.collections) { collection in
                            NavigationLink(destination: CollectionDetailView(collection: collection)) {
                                CollectionCard(collection: collection)
                            }
                        }
                    }
                    .padding()
                }
                // Add Collection Button
                Button(action: { showAddCollectionSheet = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Collection")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: profileButton) // Profile Button
            .sheet(isPresented: $showAddCollectionSheet) {
                addCollectionSheet
            }
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
                    await viewModel.addCollection(name: newCollectionName)
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
