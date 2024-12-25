//
//  File.swift
//
//
//  Created by Kosal Pen on 25/12/24.
//

import Foundation

public struct CardDetails {
    
    var cardNumber: String?
    var cardHolderName: String?
    var expiryDate: String?
    
    var cardType: String? {
        CardTypeDetector().detectCardType(for: cardNumber ?? "")
    }
}

class CardDetailsExtractor {
    
    static func extractCardDetails(from text: String) -> CardDetails {
        var cardDetails = CardDetails()
        cardDetails.cardNumber = extractCardNumber(from: text)
        cardDetails.cardHolderName = extractCardHolderName(from: text)
        cardDetails.expiryDate = extractExpiryDate(from: text)
        
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
}
