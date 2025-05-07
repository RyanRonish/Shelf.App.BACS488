//
//  Shelf_App_BACS488App.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/29/25.
//

import SwiftUI
import Firebase


@main
struct Shelf_App_BACS488App: App {

    @StateObject var authViewModel = AuthViewModel() // auth system
    @StateObject var appViewModel = AppViewModel() // scanner system
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel) // pass auth
                .environmentObject(appViewModel)    // pass scanner 
                //.task {
                    //await appViewModel.requestDataScannerAccessStatus() // requests the camera access on launch
                //}
        }
    }
}
