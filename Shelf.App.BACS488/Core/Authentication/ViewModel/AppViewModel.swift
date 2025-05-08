//
//  AppViewModel.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 3/7/25.
//

import Foundation
import AVKit
import Foundation
import SwiftUI
import VisionKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

enum ScanType: String {
    case barcode, text, bookCover //added bookcover option
}

enum DataScannerAccessStatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

@MainActor
final class AppViewModel: ObservableObject {
    
    @Published var dataScannerAccessStatus: DataScannerAccessStatusType = .notDetermined
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .barcode
    @Published var textContentType: DataScannerViewController.TextContentType?
    @Published var recognizesMultipleItems = true
    @Published var scannedBook: Book?
    @Published var allBooks: [Book] = []
    
    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        switch scanType {
        case .barcode:
            return .barcode()
        case .text, .bookCover:
            return .text(textContentType: .none) // book covers will extract raw text
        }
    }
    
    var headerText: String {
        if recognizedItems.isEmpty {
            return "Scanning \(scanType.rawValue)"
        } else {
            return "Recognized \(recognizedItems.count) item(s)"
        }
    }
    
      var dataScannerViewId: Int {
        var hasher = Hasher()
        hasher.combine(scanType)
        hasher.combine(recognizesMultipleItems)
        if let textContentType {
            hasher.combine(textContentType)
        }
        return hasher.finalize()
    }
    
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func books(in collection: BookCollection) -> [Book] {
        allBooks.filter { $0.collectionID == collection.id }
    }
    
    func fetchBooks(for collection: BookCollection) {
        // Get user
        guard let user = Auth.auth().currentUser else { return }
        guard let collectionID = collection.id else { return }

        Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .collection("collections")
            .document(collectionID)
            .collection("books")
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    self.allBooks = documents.compactMap { try? $0.data(as: Book.self) }
                }
            }
    }
    
    func requestDataScannerAccessStatus() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
            
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            } else {
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
        
        default: break
            
        }
    }
    
    
}
