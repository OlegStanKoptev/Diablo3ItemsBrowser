//
//  ItemDescriptionServiceProtocol.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 10.03.2022.
//

import UIKit

typealias ItemDescriptionCompletionHandler = (DataProviderError?) -> Void

protocol ItemDescriptionServiceProtocol: DataProvider {
    func retrieveItemDescription(of item: Item, completionHandler: @escaping ItemsCompletionHandler)
    func retrieveIcon(for item: Item, forceUpdate: Bool, completionHandler: @escaping IconCompletionHandler)
}
