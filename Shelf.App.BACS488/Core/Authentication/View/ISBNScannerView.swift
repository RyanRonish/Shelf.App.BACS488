//
//  ISBNScannerView.swift
//  Shelf.App.BACS488
//
//  Created by Ryan Ronish on 1/30/25.
//
 
import SwiftUI
import Vision
import VisionKit

struct ISBNScannerView: UIViewControllerRepresentable {
    @Binding var scannedBook: Book?
    @EnvironmentObject var authViewModel: AuthViewModel
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, authViewModel: authViewModel)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ISBNScannerView
        var authViewModel: AuthViewModel
        
        init(_ parent: ISBNScannerView, authViewModel: AuthViewModel) {
            self.parent = parent
            self.authViewModel = authViewModel
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                controller.dismiss(animated: true)
                return
            }
            
            let image = scan.imageOfPage(at: 0)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.processImage(image) // ✅ Process image in background
            }
            
            DispatchQueue.main.async {
                controller.dismiss(animated: true)
            }
        }
        
        func processImage(_ image: UIImage) {
            guard let cgImage = image.cgImage else { return }
            
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    print("Error recognizing text: \(error.localizedDescription)")
                    return
                }
                
                guard let recognizedTexts = request.results as? [VNRecognizedTextObservation] else {
                    print("DEBUG: No recognized text found.")
                    return
                }
                
                let isbnCandidates = recognizedTexts.compactMap { $0.topCandidates(1).first?.string }
                
                if let isbn = isbnCandidates.first(where: { $0.count == 10 || $0.count == 13 }) {
                    DispatchQueue.main.async {
                        self.fetchBookDetails(isbn: isbn)
                    }
                } else {
                    print("DEBUG: No valid ISBN found.")
                }
            }
            
            request.recognitionLevel = .accurate
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("DEBUG: Failed to process image: \(error)")
                }
            }
        }
        
        func fetchBookDetails(isbn: String) {
            BookAPI.searchBooks(byTitle: "") { result in
                Task {
                    guard case let .success(books) = result, let book = books.first else {
                        print("DEBUG: No book found for ISBN \(isbn)")
                        return
                    }
                    
                    let scannedBook = book
                    
                    await MainActor.run {
                        if let collection = self.parent.authViewModel.selectedCollection {
                            Task {
                                await self.parent.authViewModel.addBookToCollection(collection: collection, book: scannedBook)
                            }
                        } else {
                            self.parent.scannedBook = scannedBook
                        }
                    }
                }
            }
        }
                 
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }
    }
}


#Preview {
    ISBNScannerView(scannedBook: .constant(nil))
        .environmentObject(AuthViewModel())
}

