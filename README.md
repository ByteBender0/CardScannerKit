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
3. Enter the repository URL:
- `https://github.com/your-username/CardScannerKit.git`

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
