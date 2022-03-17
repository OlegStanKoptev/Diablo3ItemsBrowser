//
//  FetchedControllerDelegateForTableView.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import UIKit
import CoreData

class FetchedControllerDelegateForTableView: NSObject, NSFetchedResultsControllerDelegate {
    weak var tableView: UITableView?
    
    init(_ tableView: UITableView?) {
        self.tableView = tableView
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView?.insertSections([sectionIndex], with: .fade)
        case .delete:
            self.tableView?.deleteSections([sectionIndex], with: .fade)
        default:
            break
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView?.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView?.deleteRows(at: [newIndexPath!], with: .fade)
        case .update:
            self.tableView?.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            self.tableView?.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView?.endUpdates()
    }
}
