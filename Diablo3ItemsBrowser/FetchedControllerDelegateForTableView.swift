//
//  FetchedControllerDelegateForTableView.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import UIKit
import CoreData

class FetchedControllerDelegateForTableView: NSObject, NSFetchedResultsControllerDelegate {
    unowned var tableView: UITableView
    unowned var viewController: UIViewController
    
    init(tableView: UITableView, viewController: UIViewController) {
        self.tableView = tableView
        self.viewController = viewController
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard viewController.viewIfLoaded?.window != nil else { return }
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard viewController.viewIfLoaded?.window != nil else { return }
        switch type {
        case .insert: self.tableView.insertSections([sectionIndex], with: .fade)
        case .delete: self.tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard viewController.viewIfLoaded?.window != nil else { return }
        switch type {
        case .insert: if let p = newIndexPath { self.tableView.insertRows(at: [p], with: .fade) }
        case .delete: if let p = newIndexPath { self.tableView.deleteRows(at: [p], with: .fade) }
        case .update: if let p = indexPath { self.tableView.reloadRows(at: [p], with: .fade) }
        case .move: if let p = indexPath, let t = newIndexPath { self.tableView.moveRow(at: p, to: t) }
        @unknown default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard viewController.viewIfLoaded?.window != nil else { return }
        self.tableView.endUpdates()
    }
}
