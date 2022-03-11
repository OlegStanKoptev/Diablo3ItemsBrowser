//
//  ItemTypesServiceProtocol.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 10.03.2022.
//

import Foundation

typealias ItemTypesCompletionHandler = (Error?) -> Void
typealias ItemsCountCompletionHandler = (ItemType, Error?) -> Void

protocol ItemTypesServiceProtocol {
    func retrieveItemTypes(completionHandler: @escaping ItemTypesCompletionHandler)
    func retrieveItemsCount(for itemType: ItemType, completionHandler: @escaping ItemsCountCompletionHandler)
}
