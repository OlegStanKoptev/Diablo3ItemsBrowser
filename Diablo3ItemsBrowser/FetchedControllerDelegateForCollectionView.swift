//
//  FetchedControllerDelegateForCollectionView.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import UIKit
import CoreData

class FetchedControllerDelegateForCollectionView: NSObject, NSFetchedResultsControllerDelegate {
    weak var collectionView: UICollectionView?
    
    init(_ collectionView: UICollectionView?) {
        self.collectionView = collectionView
    }
    
    private var _objectChanges = [NSFetchedResultsChangeType: [[IndexPath]]]()
    private var _sectionChanges = [NSFetchedResultsChangeType: IndexSet]()
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        _objectChanges.removeAll()
        _sectionChanges.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if (type == .insert || type == .delete) {
            _sectionChanges.updateValue((_sectionChanges[type] ?? []).union([sectionIndex]), forKey: type)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let collectionView = collectionView, !collectionView.visibleCells.isEmpty {
            guard let indexPath = indexPath,
              collectionView.indexPathsForVisibleItems.contains(indexPath) else {
                  return
              }
        }
        
        var optionalChangeSet = [IndexPath?]()
        
        switch type {
        case .insert: optionalChangeSet = [newIndexPath]
        case .delete: optionalChangeSet = [indexPath]
        case .move: optionalChangeSet = [indexPath, newIndexPath]
        case .update: optionalChangeSet = [indexPath]
        @unknown default: fatalError()
        }
        let changeSet = optionalChangeSet.compactMap { $0 }
        
        _objectChanges.updateValue((_objectChanges[type] ?? []) + [changeSet], forKey: type)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        defer {
            _objectChanges.removeAll()
            _sectionChanges.removeAll()
        }
        
        if let moves = _objectChanges[.move], !moves.isEmpty {
            var updatedMoves = [[IndexPath]]()
            updatedMoves.reserveCapacity(moves.count)
            
            let insertSections = _sectionChanges[NSFetchedResultsChangeType.insert]
            let deleteSections = _sectionChanges[NSFetchedResultsChangeType.delete]
            for move in moves {
                let fromIP = move[0]
                let toIP = move[1]
                
                if let deleteSections = deleteSections, deleteSections.contains(fromIP.section) {
                    if let insertSections = insertSections, !insertSections.contains(toIP.section) {
                        _objectChanges.updateValue((_objectChanges[.insert] ?? []) + [[toIP]], forKey: .insert)
                    }
                } else if let insertSections = insertSections, insertSections.contains(toIP.section) {
                    _objectChanges.updateValue((_objectChanges[.delete] ?? []) + [[fromIP]], forKey: .delete)
                } else {
                    updatedMoves.append(move)
                }
            }
            
            if !updatedMoves.isEmpty {
                _objectChanges[.move] = updatedMoves
            } else {
                _objectChanges.removeValue(forKey: .move)
            }
            
        }
        
        if let deletes = _objectChanges[.delete], !deletes.isEmpty {
            if let deletedSections = _sectionChanges[.delete] {
                _objectChanges[.delete] = deletes.filter { !deletedSections.contains($0[0].section) }
            }
            if deletes.count > 1 {
                collectionView?.reloadData()
                return
            }
        }
        
        if let inserts = _objectChanges[.insert], !inserts.isEmpty {
            if let insertedSections = _sectionChanges[.insert] {
                _objectChanges[.insert] = inserts.filter { !insertedSections.contains($0[0].section) }
            }
            if inserts.count > 1 {
                collectionView?.reloadData()
                return
            }
        }
        
        collectionView?.performBatchUpdates {
            if let deletedSections = _sectionChanges[.delete], !deletedSections.isEmpty {
                collectionView?.deleteSections(deletedSections)
            }
            if let insertedSections = _sectionChanges[.insert], !insertedSections.isEmpty {
                collectionView?.insertSections(insertedSections)
            }
            if let deletedItems = _objectChanges[.delete], !deletedItems.isEmpty {
                collectionView?.deleteItems(at: deletedItems.map { $0[0] })
            }
            if let insertedItems = _objectChanges[.insert], !insertedItems.isEmpty {
                collectionView?.insertItems(at: insertedItems.map { $0[0] })
            }
            if let reloadItems = _objectChanges[.update], !reloadItems.isEmpty {
                collectionView?.reloadItems(at: reloadItems.map { $0[0] })
            }
            
            if let moveItems = _objectChanges[.move], !moveItems.isEmpty {
                for paths in moveItems {
                    collectionView?.moveItem(at: paths[0], to: paths[1])
                }
            }
        }
    }
    
}
