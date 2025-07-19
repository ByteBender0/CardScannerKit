# CardScannerKit

`CardScannerKit` is a Swift-based library for scanning credit card details from camera feeds using Apple's Vision framework. It provides real-time text recognition to extract card numbers, cardholder names, and expiry dates, along with comprehensive card validation and type detection capabilities.

## Features

- **Real-time Camera Scanning**: Live camera feed processing with Vision framework for text recognition
- **Card Details Extraction**: Automatically extracts **card number**, **cardholder name**, and **expiry date** from scanned text
- **Card Type Detection**: Supports detection of major card types including Visa, MasterCard, American Express, Discover, and more
- **Card Validation**: Implements Luhn algorithm validation with strategy pattern for extensible validation
- **Camera Permission Handling**: Built-in camera permission management with async/await support
- **Modular Architecture**: Protocol-oriented design with separation of concerns
- **iOS 13+ Support**: Compatible with modern iOS applications

## Supported Card Types

- Visa
- MasterCard
- American Express
- Discover
- Diners Club
- JCB
- Maestro
- UnionPay
- Carte Blanche
- Switch

## Installation

### Using Swift Package Manager

1. Open your Xcode project
2. Go to **File > Swift Packages > Add Package Dependency**
3. Enter the repository URL: `https://github.com/ByteBender0/CardScannerKit`
4. Select the appropriate version or branch

### Manual Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/ByteBender0/CardScannerKit", from: "1.0.0")
]
```

## Requirements

- **iOS 13.0+**
- **Xcode 12.0+**
- **Swift 5.0+**

## Usage

### 1. Import CardScannerKit

```swift
import CardScannerKit
```

### 2. Basic Card Scanning

```swift
import UIKit
import CardScannerKit

class ViewController: UIViewController, CardScannerDelegate {
    
    private var cardScanner: CardScanner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize CardScanner
        cardScanner = CardScanner()
        cardScanner.delegate = self
        
        // Start scanning
        cardScanner.startScanning(in: self.view)
    }
    
    // MARK: - CardScannerDelegate
    
    func didScanCard(cardNumber: String, cardHolderName: String, expiryDate: String) {
        print("Card Scanned Successfully:")
        print("Card Number: \(cardNumber)")
        print("Cardholder Name: \(cardHolderName)")
        print("Expiry Date: \(expiryDate)")
        
        // Validate the card
        let validator = CardValidator(validationStrategy: LuhnValidationStrategy())
        let isValid = validator.validate(cardNumber: cardNumber)
        print("Card is valid: \(isValid)")
        
        // Detect card type
        let cardDetails = CardDetails()
        let cardType = cardDetails.cardType
        print("Card Type: \(cardType ?? "Unknown")")
    }
    
    func didFailWithError(error: Error) {
        print("Error scanning card: \(error.localizedDescription)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cardScanner.stopScanning()
    }
}
```

### 3. Camera Permission Setup

Add the following key to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan credit cards.</string>
```

### 4. Advanced Usage with Custom Validation

```swift
// Custom validation strategy
class CustomValidationStrategy: CardValidationStrategy {
    func isValid(cardNumber: String) -> Bool {
        // Your custom validation logic
        return cardNumber.count >= 13 && cardNumber.count <= 19
    }
}

// Using custom validation
let customValidator = CardValidator(validationStrategy: CustomValidationStrategy())
let isValid = customValidator.validate(cardNumber: "4111111111111111")
```

### 5. Card Details Extraction

```swift
// Extract card details from text manually
let text = "John Doe\n4111 1111 1111 1111\n12/25"
let cardDetails = CardDetailsExtractor.extractCardDetails(from: text)

print("Card Number: \(cardDetails.cardNumber ?? "Not found")")
print("Cardholder: \(cardDetails.cardHolderName ?? "Not found")")
print("Expiry: \(cardDetails.expiryDate ?? "Not found")")
```

## API Reference

### CardScanner

Main class for camera-based card scanning.

```swift
public class CardScanner: NSObject, CardScannerProtocol
```

**Methods:**
- `startScanning(in view: UIView)` - Starts the camera scanning process
- `stopScanning()` - Stops the scanning process

**Delegate:**
- `didScanCard(cardNumber:cardHolderName:expiryDate:)` - Called when card is successfully scanned
- `didFailWithError(error:)` - Called when scanning fails

### CardValidator

Validates card numbers using different strategies.

```swift
public class CardValidator
```

**Methods:**
- `validate(cardNumber: String) -> Bool` - Validates a card number
- `setValidationStrategy(_ strategy: CardValidationStrategy)` - Sets the validation strategy

### LuhnValidationStrategy

Implements the Luhn algorithm for card number validation.

```swift
public class LuhnValidationStrategy: CardValidationStrategy
```

### CardDetails

Structure containing extracted card information.

```swift
public struct CardDetails
```

**Properties:**
- `cardNumber: String?` - The card number
- `cardHolderName: String?` - The cardholder name
- `expiryDate: String?` - The expiry date
- `cardType: String?` - The detected card type

## Error Handling

The library provides several error types:

- `CardScannerError.cameraPermissionDenied` - Camera permission not granted
- `CardScannerError.cameraSetupFailed` - Failed to setup camera
- `CardScannerError.textRecognitionFailed` - Text recognition failed
- `CardScannerError.invalidCardDetails` - Invalid or incomplete card details

## Architecture

The library follows a modular, protocol-oriented design:

- **Protocols**: Define contracts for scanning, validation, and permission handling
- **Strategies**: Implement different validation approaches
- **Helpers**: Provide utility functions for text extraction
- **Validators**: Handle card type detection and validation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
