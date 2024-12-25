//
//  File.swift
//  
//
//  Created by Kosal Pen on 25/12/24.
//

import Foundation

class CardTypeDetector {
    
    func detectCardType(for cardNumber: String) -> String {
        let sanitizedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        
        if matches(pattern: CardTypePatterns.visa, cardNumber: sanitizedCardNumber) {
            return "Visa"
        } else if matches(pattern: CardTypePatterns.masterCard, cardNumber: sanitizedCardNumber) {
            return "MasterCard"
        } else if matches(pattern: CardTypePatterns.americanExpress, cardNumber: sanitizedCardNumber) {
            return "American Express"
        } else if matches(pattern: CardTypePatterns.discover, cardNumber: sanitizedCardNumber) {
            return "Discover"
        } else if matches(pattern: CardTypePatterns.dinersClub, cardNumber: sanitizedCardNumber) {
            return "Diners Club"
        } else if matches(pattern: CardTypePatterns.jcb, cardNumber: sanitizedCardNumber) {
            return "JCB"
        } else if matches(pattern: CardTypePatterns.maestro, cardNumber: sanitizedCardNumber) {
            return "Maestro"
        } else if matches(pattern: CardTypePatterns.unionPay, cardNumber: sanitizedCardNumber) {
            return "UnionPay"
        } else if matches(pattern: CardTypePatterns.carteBlanche, cardNumber: sanitizedCardNumber) {
            return "Carte Blanche"
        } else if matches(pattern: CardTypePatterns.switch, cardNumber: sanitizedCardNumber) {
            return "Switch"
        } else {
            return "Unknown"
        }
    }
    
    // Function to match the card number against a given pattern
    private func matches(pattern: String, cardNumber: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: pattern)
        return regex?.firstMatch(in: cardNumber, options: [], range: NSRange(location: 0, length: cardNumber.count)) != nil
    }
}

