//
//  File.swift
//  
//
//  Created by Kosal Pen on 25/12/24.
//

import Foundation

public class CombinedValidationStrategy: CardValidationStrategy {
    private let strategies: [CardValidationStrategy]
    
    public init(strategies: [CardValidationStrategy]) {
        self.strategies = strategies
    }
    
    public func isValid(cardNumber: String) -> Bool {
        for strategy in strategies {
            if !strategy.isValid(cardNumber: cardNumber) {
                return false
            }
        }
        return true
    }
}
