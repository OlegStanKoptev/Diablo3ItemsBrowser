//
//  ItemTypesViewController+Delegate.swift
//  Diablo3ItemsBrowser
//
//  Created by Коптев Олег Станиславович on 24.03.2022.
//

import UIKit

//extension ItemTypesViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let wasShowingItems = itemsController != nil
//        closeItemsController(animated: false)
//        UIView.animate(withDuration: 0.2) {
//            self.navigationItem.largeTitleDisplayMode = .never
//        }
//        
//        highlightCell(at: indexPath)
//        let itemsVC = ItemsViewController()
//        itemsVC.dataProvider = ServiceContext.shared.itemsService
//        itemsVC.itemType = fetchedItemTypesController.object(at: indexPath)
//        itemsVC.onViewDidAppear = { [weak itemsVC] in
//            UIView.animate(withDuration: 0.5) {
//                if let VCheight = itemsVC?.view.frame.height {
//                    collectionView.contentInset.bottom = VCheight
//                }
//            }
//            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
//        }
//        itemsVC.popViewController = { [unowned self] in
//            self.closeItemsController(animated: true)
//        }
//        
//        itemsVC.view.translatesAutoresizingMaskIntoConstraints = false
//        
////        itemsVC.view.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
//        
//        addChild(itemsVC)
//        view.addSubview(itemsVC.view)
//        itemsVC.didMove(toParent: self)
//        
//        itemsConstraints = [
//            itemsVC.view.leftAnchor.constraint(equalTo: view.leftAnchor),
//            itemsVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            itemsVC.view.rightAnchor.constraint(equalTo: view.rightAnchor),
//            
//            itemsVC.view.heightAnchor.constraint(equalTo: collectionView.heightAnchor, multiplier: 2 / 3)
//        ]
//        
//        self.itemsController = itemsVC
//        NSLayoutConstraint.activate(itemsConstraints)
//        
//        func itemsVCResetTransform() {
//            collectionView.showsVerticalScrollIndicator = false
////            itemsVC.view.transform = .identity
//        }
//        
//        if wasShowingItems {
//            itemsVCResetTransform()
//        } else {
//            UIView.animate(withDuration: 0.5) {
//                itemsVCResetTransform()
//            }
//        }
//    }
//    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        closeItemsController()
//    }
//    
//    func highlightCell(at path: IndexPath?) {
//        guard let path = path else { return }
//        highlightedCellPath = path
//        collectionView.reloadItems(at: [path])
//    }
//    
//    func unhighlightCell(at path: IndexPath?) {
//        guard let path = path else { return }
//        highlightedCellPath = nil
//        collectionView.reloadItems(at: [path])
//    }
//    
//    func closeItemsController(animated: Bool = true) {
//        guard let itemsController = itemsController else { return }
//        self.navigationItem.largeTitleDisplayMode = .always
//        unhighlightCell(at: highlightedCellPath)
//        collectionView.showsVerticalScrollIndicator = true
//        
//        func hideUnderScreen() {
////            itemsController.view.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
//        }
//        
//        func removeEnds() {
//            NSLayoutConstraint.deactivate(self.itemsConstraints)
//            itemsController.willMove(toParent: nil)
//            itemsController.view.removeFromSuperview()
//            itemsController.removeFromParent()
//            self.itemsController = nil
//        }
//        
//        if animated {
//            UIView.animate(withDuration: 0.5) {
//                hideUnderScreen()
//                self.collectionView.contentInset.bottom = 30
//            } completion: { _ in
//                removeEnds()
//            }
//        } else {
//            removeEnds()
//        }
//    }
//}
//
