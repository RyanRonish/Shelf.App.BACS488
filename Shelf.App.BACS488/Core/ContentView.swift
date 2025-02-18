//
//  ContentView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/29/25.
//


import SwiftUI
import CoreData


struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var library = Library()
    
    var body: some View {
        Group {
            if authViewModel.userSession != nil {
                HomeView()
                    .environmentObject(library)
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
