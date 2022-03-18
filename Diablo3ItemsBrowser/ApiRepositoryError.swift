//
//  ApiRepositoryError.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import Foundation

enum ApiRepositoryError: LocalizedError {
    case requestError(Error)
    case noData(Int)
    case noToken
    
    var errorDescription: String? {
        switch self {
        case .requestError(let error): return error.localizedDescription
        case .noData(let code): return "No data returned (\(code))"
        case .noToken: return "Could not retrieve access token"
        }
    }
}
