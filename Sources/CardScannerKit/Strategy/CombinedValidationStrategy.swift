//
//  File.swift
//  
//
//  Created by Kosal Pen on 25/12/24.
//

import Foundation

class CombinedValidationStrategy: CardValidationStrategy {
    private let strategies: [CardValidationStrategy]
    
    init(strategies: [CardValidationStrategy]) {
        self.strategies = strategies
    }
    
    func isValid(cardNumber: String) -> Bool {
        for strategy in strategies {
            if !strategy.isValid(cardNumber: cardNumber) {
                return false
            }
        }
        return true
    }
}
