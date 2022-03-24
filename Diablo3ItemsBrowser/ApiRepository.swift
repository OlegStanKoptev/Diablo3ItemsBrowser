//
//  ApiRepository.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import Foundation
import UIKit

class ApiRepository {
    // MARK: - Public Fields
    var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 10

        return URLSession(configuration: config)
    }()
    var authURL: URL!
    var dataURL: URL!
    var iconsURL: URL!
    
    var clientId: String = ""
    var clientSecret: String = ""
    
    var tokenStorage: TokenStorage!
    
    // MARK: - Private Fields
//    private var accessToken: String?
    private var gettingAccessToken = false
    private var accessTokenWaiters = [(String, (Result<Data, ApiRepositoryError>) -> Void)]()
    private func iconURL(of name: String, size: IconSize) -> URL {
        iconsURL.appendingPathComponent(size.rawValue).appendingPathComponent(name).appendingPathExtension("png")
    }
    
    // MARK: - Public Methods
    func configured(configure: (ApiRepository) -> Void) -> Self {
        configure(self)
        return self
    }
    
    private func updateAccessToken(completionHandler: @escaping (ApiRepositoryError?) -> ()) {
        let tokenURL = authURL.appendingPathComponent("token")
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        guard let authHeader = "\(clientId):\(clientSecret)".data(using: .utf8)?
                .base64EncodedString() else {
            preconditionFailure()
        }
        request.setValue("Basic \(authHeader)", forHTTPHeaderField: "Authorization")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        getRequest(request) { data in
            do {
                let response = try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
                NSLog("received token: \(response.accessToken ?? "nil")")
                self.tokenStorage.saveToken(response)
                completionHandler(nil)
            } catch {
                completionHandler(.requestError(error))
            }
        } onFailure: { error in
            completionHandler(.requestError(error))
        }
    }
    
    func getData(
        from path: String,
        completionHandler: @escaping (Result<Data, ApiRepositoryError>) -> Void
    ) {
        guard let token = tokenStorage.getToken() else {
            accessTokenWaiters.append((path, completionHandler))
            if !gettingAccessToken {
                gettingAccessToken = true
                updateAccessToken { error in
                    self.gettingAccessToken = false
                    if let error = error {
                        self.accessTokenWaiters.forEach { $0.1(.failure(error)) }
                    } else {
                        self.accessTokenWaiters.forEach { self.getData(from: $0.0, completionHandler: $0.1) }
                    }
                    self.accessTokenWaiters.removeAll()
                }
            }
            return
        }
        let headers = ["Authorization": "Bearer \(token)"]
        let itemTypesURL = dataURL.appendingPathComponent(path)
        var request = URLRequest(url: itemTypesURL)
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        getRequest(request) { data in
            completionHandler(.success(data))
        } onFailure: { error in
            completionHandler(.failure(.requestError(error)))
        }
    }
    
    func getIconData(
        of iconName: String,
        size: IconSize,
        completionHandler: @escaping (Result<Data, ApiRepositoryError>) -> Void
    ) {
        getRequest(URLRequest(url: iconURL(of: iconName, size: size))) { data in
            completionHandler(.success(data))
        } onFailure: { error in
            completionHandler(.failure(.requestError(error)))
        }
    }
    
    // MARK: - Private Methods
    private func retrieveToken() -> Bool {
        return true
    }
    
    
    private func getRequest(
        _ request: URLRequest,
        onSuccess: @escaping (Data) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        var request = request
        NSLog("HTTP Request to \(request.url?.absoluteString ?? "nil")")
        urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error { onFailure(error); return }
            guard let httpResponse = response as? HTTPURLResponse else { preconditionFailure() }
            
            if (httpResponse.statusCode == 401) {
                request.setValue("Bearer token", forHTTPHeaderField: "Authorization")
                self.getRequest(request, onSuccess: onSuccess, onFailure: onFailure)
                return
            }
            
            guard let data = data else { onFailure(ApiRepositoryError.noData(httpResponse.statusCode)); return }
            onSuccess(data)
        }.resume()
    }
}
