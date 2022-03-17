//
//  BlizzardItemTypesService.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 10.03.2022.
//

import Foundation
import CoreData

struct BlizzardItemTypesService: ItemTypesServiceProtocol {
    private var decoder = JSONDecoder()
    func retrieveItemTypes(completionHandler: @escaping ItemTypesCompletionHandler) {
        ServiceContext.shared.repository.getData(from: ItemType.path) { result in
            switch result {
            case .success(let data):
                NSFetchResultsControllerHelper.shared.performOnBackgroundContext { context in
                    decoder.userInfo[.managedObjectContext] = context
                    _ = try self.decoder.decode([ItemType].self, from: data)
                } completionHandler: { completionHandler($0) }
            case .failure(let error):
                completionHandler(.innerError(error))
            }
        }
    }
    func retrieveItemsCount(for itemType: ItemType, completionHandler: @escaping ItemsCountCompletionHandler) {
        guard let path = itemType.path else {
            completionHandler(itemType, .withMessage("No path provided"))
            return
        }
        ServiceContext.shared.repository.getData(from: path) { result in
            switch result {
            case .success(let data):
                NSFetchResultsControllerHelper.shared.performOnBackgroundContext { context in
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let jsonArray = jsonObject as? [[String: Any]] else {
                        throw DataProviderError.withMessage("Items count request failed: body is not an array")
                    }
                    itemType.itemsCount = Int32(jsonArray.count)
                } completionHandler: { completionHandler(itemType, $0) }
            case .failure(let error):
                completionHandler(itemType, .innerError(error))
            }
        }
    }
}


