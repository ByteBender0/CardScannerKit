# CardScannerKit

`CardScannerKit` is a Swift-based library for scanning credit card details from images or camera feeds. It leverages Apple's Vision framework to recognize text (card number, cardholder name, and expiry date) from images or live camera input, making it easy to extract the necessary information for your mobile payment solutions or card management apps.

## Features

- **Text Recognition**: Extracts **card number**, **cardholder name**, and **expiry date** from images or camera feeds using the Vision framework.
- **Camera Permission Handling**: Asks for and checks camera permissions using a helper class.
- **Modular Architecture**: Well-structured code following best practices like separation of concerns and protocol-oriented design.
- **Customizable**: Can be easily extended to support additional functionality or features.

## Installation

### Using Swift Package Manager

You can add `CardScannerKit` as a dependency to your Xcode project using **Swift Package Manager**.

1. Open your Xcode project.
2. Go to **File > Swift Packages > Add Package Dependency**.
3. Enter the repository URL: `https://github.com/ByteBender0/CardScannerKit`

4. Select the appropriate version or branch for your project.

### Manual Installation

If you're using a local version of the `CardScannerKit` package, you can add it by dragging and dropping the folder into your project or referencing it in your `Package.swift` file.

## Requirements

- **iOS 13.0+**
- **Xcode 12.0+**
- **Swift 5.0+**

## Usage

### 1. **Import CardScannerKit**

In your view controller or wherever you want to use the scanner, import `CardScannerKit`:

```swift
import CardScannerKit
```

### 2. **Set Up CardScanner**

In your `ViewController`, create an instance of CardScanner and set the delegate to handle the scan results.

```
import UIKit
import CardScannerKit

class ViewController: UIViewController, CardScannerDelegate {
    
    private var cardScanner: CardScanner!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the CardScanner with a delegate
        cardScanner = CardScanner()
        cardScanner.delegate = self
        
        // Start scanning
        cardScanner.startScanning(in: self.view)
    }
    
    // Delegate method when scan is successful
    func didScanCard(cardNumber: String, cardHolderName: String, expiryDate: String) {
        print("Card Scanned Successfully:")
        print("Card Number: \(cardNumber)")
        print("Cardholder Name: \(cardHolderName)")
        print("Expiry Date: \(expiryDate)")
    }
    
    // Delegate method when scan fails
    func didFailWithError(error: Error) {
        print("Error scanning card: \(error.localizedDescription)")
    }
}
```
### 3. **Add Camera Permission to Info.plist**
To use the camera for scanning, make sure to add the following key to your Info.plist to request camera access permission from the user:
```
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to scan the card.</string>

```

This will display a message explaining why the app needs access to the camera.

### 4. **Start Scanning**

Call the `startScanning(in:)` method to begin scanning. You can pass any UIView (e.g., the main view of your ViewController) where the camera feed will be displayed.

```
cardScanner.startScanning(in: self.view)
```

This will initiate the camera feed and display the live video. Once the card is detected and processed, the results will be sent to the didScanCard delegate method.

### 5. **Stop Scanning**

To stop scanning at any time, you can call the `stopScanning()` method:

```
cardScanner.stopScanning()
```
This will stop the camera feed and the scanning process.

### 6. **Delegate Methods**

Once the card is scanned successfully, the delegate method didScanCard will be triggered, and you can print or process the card details:

```
Card Scanned Successfully:
Card Number: 4111 1111 1111 1111
Cardholder Name: John Doe
Expiry Date: 12/25
```
If the scanning fails, the didFailWithError method will be triggered, and you will get an error message:

```
Error scanning card: The card could not be detected.

```

### 7. **Error Handling**
In case of errors, you can show appropriate error messages to the user or take any other necessary action. For example:
```
func didFailWithError(error: Error) {
    print("Error scanning card: \(error.localizedDescription)")
    // Handle error (e.g., show an alert to the user)
}
```

## Conclusion
The CardScannerKit makes it easy to scan credit card information using the camera. By following the steps outlined in this guide, you can integrate the CardScanner into your app, handle scanning results, and validate the scanned card details.

This usage section should give you a clear understanding of how to use the CardScannerKit in your project. Feel free to modify or extend the functionality based on your app's requirements.
