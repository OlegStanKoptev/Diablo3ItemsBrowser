//
//  ServiceContext.swift
//  Diablo3ItemsBrowser
//
//  Created by Коптев Олег Станиславович on 17.03.2022.
//

import CoreData

class ServiceContext: DataProviderContext {
    private init() {}
    static private(set) var shared = ServiceContext()
    
    static func configure(configurator: (ServiceContext) -> Void) {
        configurator(shared)
    }
    
    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }
    var persistentContainer: NSPersistentContainer!
    var repository: ApiRepository!
    var itemTypesService: ItemTypesServiceProtocol!
    var itemsService: ItemsServiceProtocol!
    var itemDescriptionService: ItemDescriptionServiceProtocol!
}
