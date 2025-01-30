//
//  ContentView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/29/25.
//

// Test to see if this makes it to Github




import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                ProfileView()
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
