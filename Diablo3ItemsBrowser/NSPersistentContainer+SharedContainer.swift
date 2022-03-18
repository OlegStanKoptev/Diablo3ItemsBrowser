//
//  NSPersistenContainer+SharedContainer.swift
//  Diablo3ItemsBrowser
//
//  Created by Коптев Олег Станиславович on 17.03.2022.
//

import CoreData

extension NSPersistentContainer {
    static func newContainerForCurrentProject() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Model")

        container.loadPersistentStores { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error: \(error), \(error.userInfo)")
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true

        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }
}
