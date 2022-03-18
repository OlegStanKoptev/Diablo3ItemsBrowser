//
//  DataProviderError.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import Foundation

enum DataProviderError: LocalizedError {
    case innerError(Error)
    case withMessage(String)
    
    var errorDescription: String? {
        switch self {
        case .innerError(let error): return error.localizedDescription
        case .withMessage(let message): return "DataProviderError: \(message)"
        }
    }
}
