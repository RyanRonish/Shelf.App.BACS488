//
//  ContentView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/29/25.
//


import SwiftUI
import CoreData


struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel  // handles the user auth
    @EnvironmentObject var appViewModel: AppViewModel   // handles the book scanning
    @StateObject var library = Library()                 // stores book collections
    
    var body: some View {
        Group {
            if authViewModel.userSession != nil {
                HomeView()
                    .environmentObject(library)
                    .environmentObject(appViewModel) // pass scanner functionality to HomeView
            } else {
                LoginView()
            }
        }
    }
    
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
