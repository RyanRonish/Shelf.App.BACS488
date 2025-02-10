//
//  ProfileView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/29/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var newBio: String = ""
    @State private var isEditing: Bool = false // gets edit mode for users to add dif parts to profile
    
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 72, height: 72)
                                    .clipShape(Circle())
                            } else if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 72, height: 72)
                                .clipShape(Circle())
                            } else {
                                Text(user.initials)
                                    .frame(width: 72, height: 72)
                                    .background(Color(.systemGray3))
                                    .clipShape(Circle())
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                    await viewModel.uploadProfilePicture(data: data)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text(user.fullname).font(.headline)
                            Text(user.email).font(.subheadline).foregroundColor(.gray)
                        }
                    }
                }
                
                Section("About Me") {
                    if isEditing{
                        TextField("Enter a short bio...", text: $newBio)
                        Button("Save Bio") {
                            Task {
                                await viewModel.updateUserField(field: "bio", value: newBio)
                                isEditing = false
                            }
                        }
                    } else {
                        Text(user.bio ?? "No bio added.")
                            .foregroundColor(user.bio == nil ? .gray : .primary)
                            .onTapGesture {
                                newBio = user.bio ?? ""
                                isEditing = true
                            }
                    }
                }
            }
            
            Section("Preferences") {
                Toggle("Dark Mode", isOn: Binding(
                    get: { user.isDarkModeEnabled },
                    set: { value in Task { await viewModel.updateUserField(field: "isDarkModeEnabled", value: value) } }
                ))
            }
            
            Section("Account") {
                Button("Sign Out") { viewModel.signOut() }.foregroundColor(.red)
            }
        } else {
            Text("Loading user profile...").onAppear {
                Task {
                    await viewModel.fetchUser()
                }
            }
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AuthViewModel())
    }
}
