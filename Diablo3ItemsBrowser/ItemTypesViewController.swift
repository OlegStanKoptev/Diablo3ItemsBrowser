//
//  ItemTypesViewController.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 09.03.2022.
//

import UIKit
import CoreData

final class ItemTypesViewController: LoadableContentViewController {
    var dataProvider: ItemTypesServiceProtocol!
    var collectionView: UICollectionView!
    
    let cellSizeDeterminator = 10
    
    var fetchedItemTypesControllerDelegate: NSFetchedResultsControllerDelegate!
    var fetchedItemTypesController: NSFetchedResultsController<ItemType>!
    
    var isPlanned = false
    var collectionViewLayout: MosaicLayout!
    var sizesStorage: [Int: CellSize] = [:] {
        didSet {
            if !isPlanned {
                isPlanned = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.collectionViewLayout.sizesStorage = self.sizesStorage
                    UIView.transition(with: self.collectionView, duration: 0.1) {
                        self.collectionViewLayout.invalidateLayout()
                    } completion: { finished in
                        self.isPlanned = false
                    }
                }
            }
        }
    }
    
    var highlightedCellPath: IndexPath?
    var itemsController: ItemsViewController?
    
    var itemsConstraints: [NSLayoutConstraint] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        title = "Diablo 3 Items"

        collectionViewLayout = MosaicLayout()
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(ItemTypesCollectionViewCell.self, forCellWithReuseIdentifier: ItemTypesCollectionViewCell.identifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        fetchedItemTypesControllerDelegate = FetchedControllerDelegateForCollectionView(collectionView)
        fetchedItemTypesController =
        NSFetchResultsControllerHelper.shared.makeFetchedResultsController(name: "ItemType", sortDescriptors: [
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
        ], delegate: fetchedItemTypesControllerDelegate)

        view.backgroundColor = .systemGroupedBackground

        hideContent()
        handleRefreshControl(fullScreen: true)
    }
    
    @objc func handleRefreshControl(fullScreen: Bool = false) {
        if fullScreen { startFullscreenSpinner() }
        updateData { hadError in
            guard !hadError else { return }
            if fullScreen {
                DispatchQueue.main.async {
                    self.stopFullscreenSpinner()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.collectionView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    override func updateData(completionHandler: @escaping (Bool) -> Void) {
        dataProvider.retrieveItemTypes { error in
            self.updateDataErrorHandler(error: error) {
                completionHandler($0)
            }
        }
    }
    
    override func hideContent() {
        collectionView.alpha = 0
    }
    
    override func showContent() {
        collectionView.alpha = 1
    }
}



