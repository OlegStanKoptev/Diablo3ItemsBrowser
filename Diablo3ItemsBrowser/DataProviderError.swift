//
//  DataProviderError.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import Foundation

enum DataProviderError: Error {
    case innerError(Error)
    case withMessage(String)
    
    var description: String {
        switch self {
        case .innerError(let error): return "\(error.localizedDescription)"
        case .withMessage(let message): return "\(message)"
        }
    }
}
