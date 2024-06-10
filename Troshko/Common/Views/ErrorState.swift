//
//  ErrorState.swift
//  Troshko
//
//  Created by Faris Hurić on 7. 6. 2024..
//

import Foundation

enum ErrorState: Equatable {
    case emptyField
    case invalidFormat
    case custom(message: String)
    
    var message: String {
        switch self {
        case .emptyField:
            return "This field cannot be empty"
        case .invalidFormat:
            return "Invalid format"
        case .custom(let message):
            return message
        }
    }
}
