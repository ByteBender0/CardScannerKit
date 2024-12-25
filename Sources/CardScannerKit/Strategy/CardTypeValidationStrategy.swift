//
//  CardTypeValidationStrategy.swift
//
//
//  Created by Kosal Pen on 25/12/24.
//

import Foundation

public class CardTypeValidationStrategy: CardValidationStrategy {
    private let cardTypePattern: String

    public init(cardTypePattern: String) {
        self.cardTypePattern = cardTypePattern
    }

    public func isValid(cardNumber: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: cardTypePattern)
        let range = NSRange(location: 0, length: cardNumber.count)
        return regex?.firstMatch(in: cardNumber, options: [], range: range) != nil
    }
}
