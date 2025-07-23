//
//  File.swift
//
//
//  Created by Kosal Pen on 25/12/24.
//

import Foundation

public struct CardDetails {
    
    public var cardNumber: String?
    public var cardHolderName: String?
    public var expiryDate: String?
    public var cardType: String? {
        CardTypeDetector().detectCardType(for: cardNumber ?? "")
    }
    public var cvv: String?
    public var isFront: Bool?
    
    public init(cardNumber: String? = nil, cardHolderName: String? = nil, expiryDate: String? = nil, cvv: String? = nil, isFront: Bool? = nil) {
        self.cardNumber = cardNumber
        self.cardHolderName = cardHolderName
        self.expiryDate = expiryDate
        self.cvv = cvv
        self.isFront = isFront
    }
}

class CardDetailsExtractor {
    
    static func extractCardDetails(from text: String) -> CardDetails {
        var cardDetails = CardDetails()
        cardDetails.cardNumber = extractCardNumber(from: text)
        cardDetails.cardHolderName = extractCardHolderName(from: text)
        cardDetails.expiryDate = extractExpiryDate(from: text)
        cardDetails.cvv = extractCVV(from: text)
        cardDetails.isFront = detectIsFront(cardNumber: cardDetails.cardNumber, expiry: cardDetails.expiryDate, cvv: cardDetails.cvv)
        return cardDetails
    }
    
    // Extract card number from the text using regex
    static func extractCardNumber(from text: String) -> String? {
        let pattern = "\\b(?:\\d[ -]*?){13,19}\\b"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        if let match = regex?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) {
            return (text as NSString).substring(with: match.range).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        }
        return nil
    }
    
    // Extract cardholder name (assuming it's the first line)
    static func extractCardHolderName(from text: String) -> String? {
        let lines = text.split(separator: "\n")
        return lines.first?.trimmingCharacters(in: .whitespaces)
    }
    
    // Extract expiry date from the text using regex
    static func extractExpiryDate(from text: String) -> String? {
        let pattern = "(0[1-9]|1[0-2])\\/([0-9]{2,4})"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        if let match = regex?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) {
            return (text as NSString).substring(with: match.range)
        }
        return nil
    }

    // Extract CVV from the text using regex and context keywords
    static func extractCVV(from text: String) -> String? {
        // Look for CVV/CVC/Signature context
        let contextPattern = "(?i)(CVV|CVC|Signature)[^\\d]{0,10}(\\d{3,4})"
        if let regex = try? NSRegularExpression(pattern: contextPattern) {
            let nsText = text as NSString
            if let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: nsText.length)), match.numberOfRanges > 2 {
                return nsText.substring(with: match.range(at: 2))
            }
        }
        // Fallback: look for any standalone 3-4 digit number
        let fallbackPattern = "\\b\\d{3,4}\\b"
        if let regex = try? NSRegularExpression(pattern: fallbackPattern) {
            let nsText = text as NSString
            if let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: nsText.length)) {
                return nsText.substring(with: match.range)
            }
        }
        return nil
    }

    // Heuristic: if card number and expiry are present, it's front; if only CVV, it's back
    static func detectIsFront(cardNumber: String?, expiry: String?, cvv: String?) -> Bool? {
        if let cardNumber = cardNumber, !cardNumber.isEmpty, let expiry = expiry, !expiry.isEmpty {
            return true
        }
        if let cvv = cvv, !cvv.isEmpty, (cardNumber == nil || cardNumber?.isEmpty == true) {
            return false
        }
        return nil // Unknown
    }
}
