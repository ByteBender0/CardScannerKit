//
//  File.swift
//  
//
//  Created by Kosal Pen on 25/12/24.
//

import Foundation

struct CardTypePatterns {
    
    // Visa cards: Starts with 4 and has between 13 to 19 digits
    static let visa = "^4[0-9]{12,18}$"
    
    // MasterCard cards: Starts with 51-55 or 2221-2720 and has 16 digits
    static let masterCard = "^(5[1-5][0-9]{14}|2[2-7][0-9]{14})$"
    
    // American Express cards: Starts with 34 or 37 and has 15 digits
    static let americanExpress = "^3[47][0-9]{13}$"
    
    // Discover cards: Starts with 6011, 622126-622925, 644-649, 65 and has 16 digits
    static let discover = "^(6011|622[126-925]|64[4-9]|65)[0-9]{12,15}$"
    
    // Diners Club cards: Starts with 300-305, 36, 38, 39 and has 14 digits
    static let dinersClub = "^(300|301|302|303|304|305|36|38|39)[0-9]{11}$"
    
    // JCB cards: Starts with 3528-3589 and has 16 digits
    static let jcb = "^35[2-8][0-9]{14}$"
    
    // Maestro cards: Starts with 50, 56-69 and has 12-19 digits
    static let maestro = "^(5[0-9]{1,2}|6[1-9][0-9]{2})[0-9]{10,16}$"
    
    // UnionPay cards: Starts with 62 and has 16-19 digits
    static let unionPay = "^62[0-9]{14,17}$"
    
    // Carte Blanche cards: Starts with 300-305 and has 14 digits
    static let carteBlanche = "^3[0-5][0-9]{13}$"
    
    // Switch cards: Starts with 4903, 4905, 4911, 4936, 6333, 6759 and has 16 digits
    static let `switch` = "^(4903|4905|4911|4936|6333|6759)[0-9]{12}$"
}
