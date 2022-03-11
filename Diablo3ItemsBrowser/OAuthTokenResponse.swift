//
//  OAuthTokenResponse.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import Foundation

struct OAuthTokenResponse: Decodable {
    // "access_token": "USVb1nGO9kwQlhNRRnI4iWVy2UV5j7M6h7",
    //  "token_type": "bearer",
    //  "expires_in": 86399,
    //  "scope": "example.scope"
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case sub
    }
    let accessToken: String?
    let tokenType: String?
    let expiresIn: Int?
    let sub: String?
}
