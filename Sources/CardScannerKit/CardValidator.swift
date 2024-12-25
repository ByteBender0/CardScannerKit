//
//  CardValidator.swift
//
//
//  Created by Kosal Pen on 25/12/24.
//

import Foundation

public protocol CardValidationStrategy {
    func isValid(cardNumber: String) -> Bool
}

public class CardValidator {
    private var validationStrategy: CardValidationStrategy
    
    public init(validationStrategy: CardValidationStrategy) {
        self.validationStrategy = validationStrategy
    }

    public func setValidationStrategy(_ strategy: CardValidationStrategy) {
        self.validationStrategy = strategy
    }

    public func validate(cardNumber: String) -> Bool {
        return validationStrategy.isValid(cardNumber: cardNumber)
    }
}
