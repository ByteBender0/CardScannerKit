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

fileprivate func cardScannerLocalized(_ key: String) -> String {
    return NSLocalizedString(key, tableName: "CardScanner", bundle: .main, value: key, comment: "")
}

fileprivate func cardScannerErrorMessage(_ error: Error) -> String {
    if let err = error as? CardScannerError {
        switch err {
        case .cameraPermissionDenied:
            return cardScannerLocalized("Camera permission denied. Please enable camera access in Settings.")
        case .cameraSetupFailed:
            return cardScannerLocalized("Failed to set up camera.")
        case .textRecognitionFailed:
            return cardScannerLocalized("Text recognition failed. Try again.")
        case .invalidCardDetails:
            return cardScannerLocalized("Could not detect valid card details.")
        }
    }
    return error.localizedDescription
}

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

// MARK: - Overlay View

public class CardScannerOverlayView: UIView {
    public var borderColor: UIColor = .systemGreen { didSet { setNeedsDisplay() } }
    public var borderWidth: CGFloat = 3.0 { didSet { setNeedsDisplay() } }
    public var cornerRadius: CGFloat = 16.0 { didSet { setNeedsDisplay() } }
    public var overlayAlpha: CGFloat = 0.5 { didSet { setNeedsDisplay() } }
    public var guidanceText: String? { didSet { setNeedsDisplay() } }
    public var guidanceTextColor: UIColor = .white { didSet { setNeedsDisplay() } }
    public var guidanceFont: UIFont = .systemFont(ofSize: 18, weight: .semibold) { didSet { setNeedsDisplay() } }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setFillColor(UIColor.black.withAlphaComponent(overlayAlpha).cgColor)
        ctx.fill(bounds)
        // Card rectangle
        let cardRect = CGRect(
            x: bounds.midX - bounds.width * 0.4,
            y: bounds.midY - bounds.height * 0.12,
            width: bounds.width * 0.8,
            height: bounds.height * 0.24
        )
        let path = UIBezierPath(roundedRect: cardRect, cornerRadius: cornerRadius)
        ctx.setBlendMode(.clear)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        ctx.setBlendMode(.normal)
        // Border
        borderColor.setStroke()
        path.lineWidth = borderWidth
        path.stroke()
        // Guidance text
        if let text = guidanceText {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: guidanceFont,
                .foregroundColor: guidanceTextColor,
                .paragraphStyle: paragraph
            ]
            let textRect = CGRect(x: 0, y: cardRect.maxY + 16, width: bounds.width, height: 30)
            (text as NSString).draw(in: textRect, withAttributes: attrs)
        }
    }
}

public class CardScanner: NSObject, CardScannerProtocol {
    
    var delegate: CardScannerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var sequenceHandler: VNSequenceRequestHandler?
    
    private var cameraPermissionManager: CameraPermissionHandler
    
    private var overlayView: CardScannerOverlayView?
    
    public init(cameraPermissionManager: CameraPermissionHandler = CameraPermissionManager()) {
        self.cameraPermissionManager = cameraPermissionManager
        super.init()
        sequenceHandler = VNSequenceRequestHandler()
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
        removeOverlay()
    }
    
    public func startScanning(in view: UIView) {
        Task {
            let permissionGranted = await cameraPermissionManager.checkCameraPermissions()
            
            guard permissionGranted else {
                delegate?.didFailWithError(error: CardScannerError.cameraPermissionDenied)
                return
            }
            
            setupCaptureSession(view: view)
            addOverlay(to: view)
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
    
    private func addOverlay(to view: UIView) {
        removeOverlay()
        let overlay = CardScannerOverlayView(frame: view.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.guidanceText = cardScannerLocalized("Place your card inside the frame")
        view.addSubview(overlay)
        overlayView = overlay
    }
    private func removeOverlay() {
        overlayView?.removeFromSuperview()
        overlayView = nil
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

