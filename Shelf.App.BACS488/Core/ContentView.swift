//
//  ContentView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/29/25.
//


import SwiftUI
import CoreData


struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var library = Library()
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
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
