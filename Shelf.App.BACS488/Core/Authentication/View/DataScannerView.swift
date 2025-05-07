//
//  DataScannerView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 3/7/25.
//

import Foundation
import SwiftUI
import VisionKit


struct DataScannerView: UIViewControllerRepresentable {
    
    enum RecognizedItem: Equatable {
        case text(String)
        case barcode(String)
        
        static func == (lhs: RecognizedItem, rhs: RecognizedItem) -> Bool {
            switch (lhs, rhs) {
            case (.text(let l), .text(let r)):
                return l == r
            case (.barcode(let l), .barcode(let r)):
                return l == r
            default:
                return false
            }
        }
    }
    
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizesMultipleItems: Bool
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizesMultipleItems,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        @Binding var recognizedItems: [RecognizedItem]
        
        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            for item in addedItems {
                switch item {
                case .text(let extractedText):
                    processScannedText(extractedText)
                case .barcode(let isbn):
                    fetchBookDetails(isbn: isbn)
                default:
                    break
                }
            }
        }
        
        func processScannedText(_ text: String) {
            let lines = text.components(separatedBy: "\n").filter { !$0.isEmpty }
            
            if lines.count >= 2 {
                let title = lines[0] // Assume first line is title
                let author = lines[1] // Assume second line is author
                
                let book = Book(
                    id: UUID().uuidString,
                    title: title,
                    author: author,
                    collectionID: "temp",
                    isbn: nil,
                    thumbnailURL: nil,
                    description: nil,
                    publisher: nil,
                    year: nil,
                )
                
                DispatchQueue.main.async {
                    self.recognizedItems.append(.text(book.title))
                }
            }
        }
        
        func fetchBookDetails(isbn: String) {
            BookAPI.searchBooks(byTitle: "") { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let books):
                        if let book = books.first {
                            self.recognizedItems.append(.text(book.title))
                        } else {
                            print("DEBUG: No book found for ISBN \(isbn)")
                        }
                    case .failure(let error):
                        print("DEBUG: Book API search failed - \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
    
/*
struct RecognizedItem: Equatable {
    public static func == (lhs: RecognizedItem, rhs: RecognizedItem) -> Bool {
        switch (lhs, rhs) {
        case (.text(let lText), .text(let rText)):
            return lText == rText
        case (.barcode(let lCode), .barcode(let rCode)):
            return lCode == rCode
        default:
            return false
        }
    }
}
*/
