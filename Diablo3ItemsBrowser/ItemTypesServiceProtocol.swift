//
//  ItemTypesServiceProtocol.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 10.03.2022.
//

import Foundation

typealias ItemTypesCompletionHandler = (DataProviderError?) -> Void
typealias ItemsCountCompletionHandler = (ItemType, DataProviderError?) -> Void

protocol ItemTypesServiceProtocol: DataProvider {
    func retrieveItemTypes(completionHandler: @escaping ItemTypesCompletionHandler)
    mutating func retrieveItemsCount(for itemType: ItemType, completionHandler: @escaping ItemsCountCompletionHandler)
}
