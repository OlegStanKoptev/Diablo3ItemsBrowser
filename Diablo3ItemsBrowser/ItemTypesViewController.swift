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
    
    private let cellSizeDeterminator = 30
    
    private var fetchedItemTypesControllerDelegate: NSFetchedResultsControllerDelegate!
    private var fetchedItemTypesController: NSFetchedResultsController<ItemType>!
    
    private var isPlanned = false
    private var collectionViewLayout: MosaicLayout!
    private var sizesStorage: [Int: CellSize] = [:] {
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
    private var refreshControl: UIRefreshControl!
    
    private var highlightedCellPath: IndexPath?
    private var itemsController: ItemsViewController?
    
    private var itemsConstraints: [NSLayoutConstraint] = []
    
    private var verticalIndiciatorInset: UIEdgeInsets!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        title = "Diablo 3 Items"

        collectionViewLayout = MosaicLayout()
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        verticalIndiciatorInset = collectionView.verticalScrollIndicatorInsets
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ItemTypesCollectionViewCell.self, forCellWithReuseIdentifier: ItemTypesCollectionViewCell.identifier)

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(handleRefreshControl),
            for: .valueChanged
        )
//        collectionView.refreshControl = refreshControl
        
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

extension ItemTypesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedItemTypesController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemTypesCollectionViewCell.identifier, for: indexPath) as! ItemTypesCollectionViewCell

        let itemType = fetchedItemTypesController.object(at: indexPath)
        cell.updateCellContent(with: itemType, highlighted: highlightedCellPath == indexPath)
        
        if (itemType.areItemsNotLoaded) {
            dataProvider.retrieveItemsCount(for: itemType) { itemType, error in
                if let error = error { print(error.localizedDescription) }
                self.sizesStorage[indexPath.item] = itemType.itemsCount > self.cellSizeDeterminator ? .large : .small
            }
        }

        return cell
    }
}

extension ItemTypesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wasShowingItems = itemsController != nil
        closeItemsController(animated: false)
        
        highlightCell(at: indexPath)
        let itemsVC = ItemsViewController()
        itemsVC.dataProvider = ServiceContext.shared.itemsService
        itemsVC.itemType = fetchedItemTypesController.object(at: indexPath)
        itemsVC.onViewDidAppear = {
            collectionView.contentInset.bottom = itemsVC.view.frame.height
            collectionView.verticalScrollIndicatorInsets.bottom = itemsVC.view.frame.height
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
        
        itemsVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        itemsVC.view.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        
        addChild(itemsVC)
        view.addSubview(itemsVC.view)
        
        itemsConstraints = [
            itemsVC.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            itemsVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            itemsVC.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            itemsVC.view.heightAnchor.constraint(equalTo: collectionView.heightAnchor, multiplier: 2 / 3)
        ]
        
        self.itemsController = itemsVC
        NSLayoutConstraint.activate(itemsConstraints)
        
        func itemsVCResetTransform() {
            itemsVC.view.transform = .identity
        }
        
        if wasShowingItems {
            itemsVCResetTransform()
        } else {
            UIView.animate(withDuration: 0.5) {
                itemsVCResetTransform()
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        closeItemsController()
    }
    
    func highlightCell(at path: IndexPath?) {
        guard let path = path else { return }
        highlightedCellPath = path
        collectionView.reloadItems(at: [path])
        UIView.animate(withDuration: 0.1) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    func unhighlightCell(at path: IndexPath?) {
        guard let path = path else { return }
        highlightedCellPath = nil
        collectionView.reloadItems(at: [path])
        UIView.animate(withDuration: 0.1) {
            self.navigationItem.largeTitleDisplayMode = .always
        }
    }
    
    func closeItemsController(animated: Bool = true) {
        guard let itemsController = itemsController else { return }
        unhighlightCell(at: highlightedCellPath)
        
        func hideUnderScreen() {
            itemsController.view.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        }
        
        func removeEnds() {
            NSLayoutConstraint.deactivate(self.itemsConstraints)
            itemsController.removeFromParent()
            itemsController.view.removeFromSuperview()
            self.itemsController = nil
        }
        
        if animated {
            UIView.animate(withDuration: 0.5) {
                hideUnderScreen()
                self.collectionView.contentInset.bottom = 30
                self.collectionView.verticalScrollIndicatorInsets = self.verticalIndiciatorInset
            } completion: { finished in
                guard finished, itemsController == self.itemsController else { return }
                removeEnds()
            }
        } else {
            removeEnds()
        }
    }
}
