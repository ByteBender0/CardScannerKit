import XCTest
@testable import CardScannerKit

final class CardScannerKitTests: XCTestCase {
    
    func testExample() throws {
        testLuhnValidation()
        testCardTypeValidation()
        testCombinded()
    }
    
    func testLuhnValidation() {
        let luhnValidator = LuhnValidationStrategy()
        //XCTAssertTrue(luhnValidator.isValid(cardNumber: "4111 1111 1111 1111"))
        XCTAssertFalse(luhnValidator.isValid(cardNumber: "1234 5678 9012 3456"))
    }
    
    func testCardTypeValidation() {
        let visaValidator = CardTypeValidationStrategy(cardTypePattern: CardTypePatterns.visa) // Visa
        //XCTAssertTrue(visaValidator.isValid(cardNumber: "4111 1111 1111 1111"))
        XCTAssertFalse(visaValidator.isValid(cardNumber: "5105 1051 0510 5100"))
    }
    
    func testCombinded() {
        
        // 1. Luhn Validation
        let luhnValidator = LuhnValidationStrategy()
        let cardValidator = CardValidator(validationStrategy: luhnValidator)
        let isValidLuhn = cardValidator.validate(cardNumber: "4532015112830366")
        print("Is the card valid using Luhn? \(isValidLuhn)")  // Output: true or false

        // 2. Card Type Validation (e.g., Visa card pattern)
        let visaCardPattern = "^4[0-9]{12,15}$"  // Visa cards start with 4 and have 13-16 digits
        let visaValidator = CardTypeValidationStrategy(cardTypePattern: visaCardPattern)
        cardValidator.setValidationStrategy(visaValidator)
        let isVisaValid = cardValidator.validate(cardNumber: "4532015112830366")
        print("Is the card a valid Visa? \(isVisaValid)")  // Output: true or false
        
        // Using the combined strategy
        let combinedValidator = CombinedValidationStrategy(strategies: [luhnValidator, visaValidator])
        let isCombinedValid = combinedValidator.isValid(cardNumber: "4532015112830366")
        print("Is the card valid using combined validation? \(isCombinedValid)")  // Output: true or false
    }
}
