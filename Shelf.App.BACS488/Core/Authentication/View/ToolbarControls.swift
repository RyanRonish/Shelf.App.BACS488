//
//  ToolbarControls.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 5/7/25.
//

import SwiftUI

struct ToolbarControls: ToolbarContent {
    @Binding var showDeleteConfirmation: Bool
    @Binding var showingScanner: Bool
    @Binding var isShowingBookForm: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete Collection", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }

        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                showingScanner = true
            } label: {
                Label("Scan Book", systemImage: "text.viewfinder")
            }

            Button {
                isShowingBookForm = true
            } label: {
                Label("Add Book", systemImage: "plus")
            }
        }
    }
}
