//
//  ItemsServiceProtocol.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 10.03.2022.
//

import UIKit

typealias ItemsCompletionHandler = (DataProviderError?) -> Void

protocol ItemsServiceProtocol: DataProvider {
    func retrieveItems(of itemType: ItemType, completionHandler: @escaping ItemsCompletionHandler)
    func retrieveIcon(for item: Item, forceUpdate: Bool, completionHandler: @escaping IconCompletionHandler)
}
