//
//  LuhnValidationStrategy.swift
//  
//
//  Created by Kosal Pen on 25/12/24.
//

import Foundation

public class LuhnValidationStrategy: CardValidationStrategy {
    public init() {}

    public func isValid(cardNumber: String) -> Bool {
        var sum = 0
        var shouldDouble = false

        for digit in cardNumber.reversed() {
            guard let digitInt = Int(String(digit)) else { return false }

            var currentDigit = digitInt
            if shouldDouble {
                currentDigit *= 2
                if currentDigit > 9 {
                    currentDigit -= 9
                }
            }

            sum += currentDigit
            shouldDouble.toggle()
        }

        return sum % 10 == 0
    }
}
