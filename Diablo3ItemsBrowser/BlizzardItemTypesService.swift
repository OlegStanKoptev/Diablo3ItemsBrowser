//
//  BlizzardItemTypesService.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 10.03.2022.
//

import Foundation

struct BlizzardItemTypesService: ItemTypesServiceProtocol {
    func retrieveItemTypes(completionHandler: @escaping ItemTypesCompletionHandler) {
        completionHandler(nil)
    }
    func retrieveItemsCount(for itemType: ItemType, completionHandler: @escaping ItemsCountCompletionHandler) {
        completionHandler(itemType, nil)
    }
}
