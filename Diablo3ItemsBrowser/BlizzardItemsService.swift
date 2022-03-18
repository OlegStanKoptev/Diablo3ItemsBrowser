//
//  BlizzardItemsService.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 10.03.2022.
//

import UIKit

class BlizzardItemsService: ItemsServiceProtocol {
    internal init(iconProvider: IconProvider) {
        self.iconProvider = iconProvider
    }
    
    var iconProvider: IconProvider
    private let decoder = JSONDecoder()
        
    func retrieveItems(of itemType: ItemType, completionHandler: @escaping ItemsCompletionHandler) {
        guard let path = itemType.path else {
            completionHandler(.withMessage("No path provided"))
            return
        }
        ServiceContext.shared.repository.getData(from: path) { result in
            switch result {
            case .success(let data):
                NSFetchResultsControllerHelper.shared.performOnBackgroundContext { context in
                    self.decoder.userInfo[.managedObjectContext] = context
                    self.decoder.userInfo[.itemTypeForItem] = itemType.id
                    _ = try self.decoder.decode([Item].self, from: data)
                } completionHandler: { completionHandler($0) }
            case .failure(let error):
                completionHandler(.innerError(error))
            }
        }
    }
    
    func retrieveIcon(for item: Item, forceUpdate: Bool, completionHandler: @escaping IconCompletionHandler) {
        guard let iconName = item.icon else {
            completionHandler(UIImage(systemName: "xmark.octagon"), .withMessage("Item without name"))
            return
        }
        iconProvider.retrieveIcon(iconName: iconName, size: .small, completionHandler: completionHandler)
    }
}
