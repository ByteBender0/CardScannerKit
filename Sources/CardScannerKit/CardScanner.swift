//
//  CardScanner.swift
//
//
//  Created by Kosal Pen on 25/12/24.
//

import AVFoundation
import Vision
#if canImport(UIKit)
import UIKit

public protocol CameraPermissionHandler {
    func checkCameraPermissions() async -> Bool
}

// Protocol to handle card scanning and processing
protocol CardScannerProtocol {
    var delegate: CardScannerDelegate? { get set }
    func startScanning(in view: UIView)
    func stopScanning()
}

protocol CardScannerDelegate: AnyObject {
    func didScanCard(cardNumber: String, cardHolderName: String, expiryDate: String)
    func didFailWithError(error: Error)
}

public class CameraPermissionManager: CameraPermissionHandler {
    
    public init() {}
    
    public func checkCameraPermissions() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { response in
                continuation.resume(returning: response)
            }
        }
    }
}

enum CardScannerError: Error {
    case cameraPermissionDenied
    case cameraSetupFailed
    case textRecognitionFailed
    case invalidCardDetails
}

public class CardScanner: NSObject, CardScannerProtocol {
    
    var delegate: CardScannerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var sequenceHandler: VNSequenceRequestHandler?
    
    private var cameraPermissionManager: CameraPermissionHandler
    
    public init(cameraPermissionManager: CameraPermissionHandler = CameraPermissionManager()) {
        self.cameraPermissionManager = cameraPermissionManager
        super.init()
        sequenceHandler = VNSequenceRequestHandler()
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
    }
    
    public func startScanning(in view: UIView) {
        Task {
            let permissionGranted = await cameraPermissionManager.checkCameraPermissions()
            
            guard permissionGranted else {
                delegate?.didFailWithError(error: CardScannerError.cameraPermissionDenied)
                return
            }
            
            setupCaptureSession(view: view)
        }
    }
    
    private func setupCaptureSession(view: UIView) {
        captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.didFailWithError(error: CardScannerError.cameraSetupFailed)
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            let photoOutput = AVCapturePhotoOutput()
            captureSession?.addInput(input)
            captureSession?.addOutput(photoOutput)
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
            
            captureSession?.startRunning()
            startTextRecognition()
        } catch {
            delegate?.didFailWithError(error: CardScannerError.cameraSetupFailed)
        }
    }
    
    private func startTextRecognition() {
        guard let captureSession = captureSession else { return }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInitiated))
        captureSession.addOutput(output)
    }
}

extension CardScanner: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                self.delegate?.didFailWithError(error: error ?? CardScannerError.textRecognitionFailed)
                return
            }
            
            if let results = request.results, let observation = results.first as? VNRecognizedTextObservation {
                let recognizedText = observation.topCandidates(1).first?.string ?? ""
                
                let cardDetails = CardDetailsExtractor.extractCardDetails(from: recognizedText)
                let cardNumber = cardDetails.cardNumber
                let cardHolderName = cardDetails.cardHolderName
                let expiryDate = cardDetails.expiryDate
                
                if let cardNumber = cardNumber, let cardHolderName = cardHolderName, let expiryDate = expiryDate {
                    self.delegate?.didScanCard(cardNumber: cardNumber, cardHolderName: cardHolderName, expiryDate: expiryDate)
                } else {
                    self.delegate?.didFailWithError(error: CardScannerError.invalidCardDetails)
                }
            }
        }
        
        do {
            try sequenceHandler?.perform([request], on: pixelBuffer)
        } catch {
            self.delegate?.didFailWithError(error: error)
        }
    }
}

// MARK: - Image-Based Scanning

extension CardScanner {
    /// Scans card details from a static UIImage (photo library, screenshot, etc.)
    /// - Parameters:
    ///   - image: The UIImage to scan
    ///   - completion: Completion handler with Result<CardDetails, Error>
    public func scanImage(_ image: UIImage, completion: @escaping (Result<CardDetails, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(CardScannerError.invalidCardDetails))
            return
        }
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completion(.failure(error ?? CardScannerError.textRecognitionFailed))
                return
            }
            let recognizedText = (request.results as? [VNRecognizedTextObservation])?
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n") ?? ""
            let cardDetails = CardDetailsExtractor.extractCardDetails(from: recognizedText)
            if let cardNumber = cardDetails.cardNumber, let cardHolderName = cardDetails.cardHolderName, let expiryDate = cardDetails.expiryDate {
                completion(.success(cardDetails))
            } else {
                completion(.failure(CardScannerError.invalidCardDetails))
            }
        }
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
}
#endif

