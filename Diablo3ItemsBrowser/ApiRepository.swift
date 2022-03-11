//
//  ApiRepository.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import Foundation

class ApiRepository {
    // MARK: Singleton, yeeee
    private init() {}
    static let shared = ApiRepository()

    // MARK: - Fields
    var urlSession = URLSession.shared
    var authURL: URL!
    var dataURL: URL!
    var iconsURL: URL!
    private func iconURL(of name: String, size: IconSize) -> URL {
        iconsURL.appendingPathComponent(size.rawValue).appendingPathComponent(name).appendingPathExtension("png")
    }
    
    var clientId: String = ""
    var clientSecret: String = ""
    
    private var accessToken: String?
    
    // MARK: - Public Methods
    
    func configure(configure: (ApiRepository) -> Void) {
        configure(self)
    }
    
    func getToken(completionHandler: @escaping () -> ()) {
        guard accessToken == nil else { completionHandler(); return }
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
                self.accessToken = response.accessToken
                NSLog("received token: \(response.accessToken ?? "nil")")
                completionHandler()
            } catch {
                fatalError()
            }
        } onFailure: { error in
            fatalError()
        }
    }
    
    func getData(
        from path: String,
        completionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let token = accessToken else { getToken { self.getData(from: path, completionHandler: completionHandler) }; return }
        let headers = ["Authorization": "Bearer \(token)"]
        let itemTypesURL = dataURL.appendingPathComponent(path)
        var request = URLRequest(url: itemTypesURL)
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        getRequest(request) { data in
            completionHandler(.success(data))
        } onFailure: { error in
            completionHandler(.failure(error))
        }
    }
    
    func getIconData(
        of iconName: String,
        size: IconSize,
        completionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        getRequest(URLRequest(url: iconURL(of: iconName, size: size))) { data in
            completionHandler(.success(data))
        } onFailure: { error in
            completionHandler(.failure(error))
        }
    }
    
    // MARK: - Private Methods
    private func getRequest(
        _ request: URLRequest,
        onSuccess: @escaping (Data) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        NSLog("DataTask with request to \(request.url?.absoluteString ?? "nil")")
        urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error { onFailure(error); return }
            guard let httpResponse = response as? HTTPURLResponse else { preconditionFailure() }
            guard let data = data else { onFailure(ApiRepositoryError.noData(httpResponse.statusCode)); return }
            onSuccess(data)
        }.resume()
    }
}
