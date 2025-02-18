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

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ISBNScannerView
        
        init(_ parent: ISBNScannerView) {
            self.parent = parent
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
            BookAPI.shared.fetchBookDetails(isbn: isbn) { book in
                DispatchQueue.main.async {
                    self.parent.scannedBook = book
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
}

