//
//  AddBookView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//

import SwiftUI

enum ActiveSheet: Identifiable {
    case scanner
    case manual

    var id: Int { hashValue }
}

struct AddBookView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var activeSheet: ActiveSheet? = nil
    @State private var scannedBook: Book?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add a Book to Your Collection")
                    .font(.title2)
                    .bold()
                    .padding()
                
                // 📌 Scan Book Button
                Button(action: {
                    activeSheet = .scanner
                }) {
                    Label("Scan Book Barcode", systemImage: "barcode.viewfinder")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // 📌 Manual Book Entry Button
                Button(action: {
                    activeSheet = .manual
                }) {
                    Label("Enter Book Manually", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // 📌 Display Scanned Book Details
                if let book = scannedBook {
                    VStack {
                        Text("Scanned Book Details")
                            .font(.headline)
                            .padding(.top)
                        
                        if let url = URL(string: book.thumbnailURL) {
                            AsyncImage(url: url)
                                .frame(width: 100, height: 150)
                                .cornerRadius(10)
                        }
                        
                        Text("Title: \(book.title)")
                            .font(.subheadline)
                            .bold()
                        Text("Author: \(book.author)")
                            .font(.subheadline)
                        Text("ISBN: \(book.isbn)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .padding()
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .scanner:
                    ISBNScannerView(scannedBook: $scannedBook)
                case .manual:
                    ManualBookEntryView()
                        .environmentObject(viewModel)
                }
            }
        }
    }
}


#Preview {
    AddBookView()
}


