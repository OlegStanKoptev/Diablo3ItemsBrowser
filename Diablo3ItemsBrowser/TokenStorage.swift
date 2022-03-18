//
//  TokenStorage.swift
//  Diablo3ItemsBrowser
//
//  Created by Коптев Олег Станиславович on 18.03.2022.
//

import Foundation

struct TokenStorage {
    private let defaults = UserDefaults.standard
    private let tokenDefaultsKey = "AccessToken"
    private let tokenExpirationDefaultsKey = "AccessTokenExpirationTime"
    
    func getToken() -> String? {
        let storedValue = defaults.string(forKey: tokenDefaultsKey)
        let expirationTime = defaults.double(forKey: tokenExpirationDefaultsKey)
        return Date().timeIntervalSince1970 < expirationTime ? storedValue : nil
    }
    
    mutating func saveToken(_ response: OAuthTokenResponse) {
        defaults.set(response.accessToken, forKey: tokenDefaultsKey)
        let expirationTime = Date().timeIntervalSince1970 + Double(response.expiresIn ?? 0)
        defaults.set(expirationTime, forKey: tokenExpirationDefaultsKey)
    }
}
