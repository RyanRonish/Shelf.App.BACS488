//
//  AddBookView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//
/*
import SwiftUI

struct AddBookView: View {
    @State private var showScanner = false
    @State private var showManualEntry = false
    @State private var scannedBook: Book?

    var body: some View {
        VStack(spacing: 20) {
            Text("Add a Book to Your Collection")
                .font(.title2)
                .bold()
                .padding()
            
            Button(action: {
                showScanner = true
            }) {
                Label("Scan Book Barcode", systemImage: "barcode.viewfinder")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                showManualEntry = true
            }) {
                Label("Enter Book Manually", systemImage: "square.and.pencil")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if let book = scannedBook {
                VStack {
                    Text("Scanned Book Details")
                        .font(.headline)
                        .padding(.top)

                    if let imageURL = book.thumbnailURL, let url = URL(string: imageURL) {
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
        .sheet(isPresented: $showScanner) {
            ISBNScannerView(scannedBook: $scannedBook)
        }
        .sheet(isPresented: $showManualEntry) {
            ManualBookEntryView()
        }
    }
}

#Preview {
    AddBookView()
}

*/
