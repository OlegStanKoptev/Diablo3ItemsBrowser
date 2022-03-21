//
//  ItemsViewController.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 10.03.2022.
//

import UIKit
import CoreData

class ItemsViewController: LoadableContentViewController {
    var dataProvider: ItemsServiceProtocol!
    var tableView: UITableView!
    var itemType: ItemType!
    var onViewDidAppear: () -> Void = {}
    var popViewController: () -> Void = {}
    private var onViewDidAppearFired = false
    
    private var fetchedItemsControllerDelegate: NSFetchedResultsControllerDelegate!
    private var fetchedItemsController: NSFetchedResultsController<Item>!
    
    private var updateCachedImage: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = itemType.name

        tableView = UITableView(frame: self.view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ItemsTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(tableView)
        
        guard let itemTypeId = itemType.id else { preconditionFailure() }
        
        fetchedItemsControllerDelegate = FetchedControllerDelegateForTableView(tableView: tableView)
        fetchedItemsController = NSFetchResultsControllerHelper.shared.makeFetchedResultsController(
            name: "Item",
            sortDescriptors: [
                NSSortDescriptor(key: "name", ascending: true),
                NSSortDescriptor(key: "id", ascending: true)
            ],
            predicate: NSPredicate(format: "itemType == %@", itemTypeId),
            delegate: fetchedItemsControllerDelegate
        )
        
        view.backgroundColor = .systemGroupedBackground
        
        hideContent()
        handleRefreshControl(fullScreen: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPaths = tableView.indexPathsForSelectedRows {
            UIView.animate(withDuration: 0.25) { [unowned self] in
                indexPaths.forEach { self.tableView.deselectRow(at: $0, animated: true) }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !onViewDidAppearFired {
            onViewDidAppear()
            onViewDidAppearFired = true
        }
    }
    
    @objc func handleRefreshControl(fullScreen: Bool = false) {
        updateCachedImage = true
        if fullScreen { startFullscreenSpinner() }
        updateData { [weak self] hadError in
            guard !hadError else { return }
            if fullScreen {
                DispatchQueue.main.async {
                    self?.stopFullscreenSpinner()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    override func updateData(completionHandler: @escaping (Bool) -> Void) {
        dataProvider.retrieveItems(of: itemType) { error in
            self.updateDataErrorHandler(error: error) { [weak self] in
                if (self?.fetchedItemsController.fetchedObjects?.isEmpty ?? true) {
                    self?.popViewController()
                }
            } completionHandler: { hadError in
                completionHandler(hadError)
            }
        }
    }
    
    override func hideContent() {
        tableView.alpha = 0
    }
    
    override func showContent() {
        tableView.alpha = 1
    }
}

extension ItemsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedItemsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemsTableViewCell

        let item = fetchedItemsController.object(at: indexPath)
        cell.updateCellContent(with: item)
        
        cell.startLoadingAnimation()
        
        
        dataProvider.retrieveIcon(for: item, forceUpdate: updateCachedImage) { [weak self] image, error in
            self?.updateCachedImage = false
            DispatchQueue.main.async {
                cell.stopLoadingAnimationAndSetContentImage(image)
            }
        }

        return cell
    }
}

extension ItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ItemDescriptionViewController()
        vc.dataProvider = ServiceContext.shared.itemDescriptionService
        vc.item = fetchedItemsController.object(at: indexPath)

        navigationController?.pushViewController(vc, animated: true)
    }
}

