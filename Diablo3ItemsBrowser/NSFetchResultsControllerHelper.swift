//
//  NSFetchResultsControllerHelper.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import CoreData

class NSFetchResultsControllerHelper {
    private init() {}
    static let shared = NSFetchResultsControllerHelper()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var persistentContainer: NSPersistentContainer {
        return ServiceContext.shared.persistentContainer
    }
    
    /// Create a new NSFetchedResultsController, configured to be used in view controllers.
    /// Creates a fetch request, adds sort descriptors, predicate, sets delegate and performs fetch.
    /// - Returns: New NSFetchedResultsController
    func makeFetchedResultsController<T: NSManagedObject>(name: String, sortDescriptors: [NSSortDescriptor] = [], predicate: NSPredicate? = nil, delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<T> {
        let fetchRequest = NSFetchRequest<T>(entityName: name)
        fetchRequest.sortDescriptors = sortDescriptors
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)

        controller.delegate = delegate

        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        return controller
    }
    
    func performOnBackgroundContext(context inContext: NSManagedObjectContext? = nil, _ task: (NSManagedObjectContext) throws -> Void, completionHandler: (DataProviderError?) -> Void = {_ in}) {
        let context = inContext ?? makeBackgroundContext()
        context.performAndWait {
            do {
                try task(context)
            } catch {
                completionHandler(.innerError(error))
            }
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                context.reset()
            }
            completionHandler(nil)
        }
    }
    
    private func makeBackgroundContext() -> NSManagedObjectContext {
        let taskContext = self.persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.automaticallyMergesChangesFromParent = true
        return taskContext
    }
}
