//
//  Shelf_App_BACS488App.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/29/25.
//

import SwiftUI
import Firebase



//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//    return true
//  }
//}

@main
struct Shelf_App_BACS488App: App {
    //let persistenceController = PersistenceController.shared
    // register app delegate for Firebase setup
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            //NavigationView {
                ContentView()
                //.environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(authViewModel)
            }
        //}
    }
}
