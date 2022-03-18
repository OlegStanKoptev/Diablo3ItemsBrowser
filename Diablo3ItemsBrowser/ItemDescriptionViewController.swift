//
//  ItemDescriptionViewController.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 10.03.2022.
//

import UIKit
import CoreData

class ItemDescriptionViewController: LoadableContentViewController {
    var dataProvider: ItemDescriptionServiceProtocol!
    var tableView: UITableView!
    var item: Item!
    private var itemDescription: [(String, String)] = []
    
    private var fetchedItemDescriptionControllerDelegate: NSFetchedResultsControllerDelegate!
    private var fetchedItemDescriptionController: NSFetchedResultsController<ItemDescription>!
    
    private var updateCachedImage: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = item.name
        
        navigationItem.largeTitleDisplayMode = .always
        
        tableView = UITableView(frame: self.view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ItemDescriptionIconTableViewCell.self, forCellReuseIdentifier: "IconCell")
        tableView.register(ItemDescriptionTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.allowsSelection = false
        
//        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(
            self,
            action: #selector(handleRefreshControl),
            for: .valueChanged
        )
        
        view.addSubview(tableView)
        
        fetchedItemDescriptionControllerDelegate = self
        fetchedItemDescriptionController = NSFetchResultsControllerHelper.shared.makeFetchedResultsController(
            name: "ItemDescription",
            predicate: NSPredicate(format: "id == %@", item.id!),
            delegate: fetchedItemDescriptionControllerDelegate
        )
        
        view.backgroundColor = .systemGroupedBackground
        
        hideContent()
        handleRefreshControl(fullScreen: true)
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
        dataProvider.retrieveItemDescription(of: item) { error in
            self.updateDataErrorHandler(error: error) {
                if (self.fetchedItemDescriptionController.fetchedObjects?.isEmpty ?? true) {
                    self.navigationController?.popViewController(animated: true)
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
    
    func dataForCell(at indexPath: IndexPath) -> (String, String)? {
        guard indexPath.row > 0 else { return nil }
        return itemDescription[indexPath.row - 1]
    }
    
    func extractDescriptionFromDB(_ anObject: Any? = nil) {
        let anObject = (anObject as? ItemDescription) ?? fetchedItemDescriptionController.fetchedObjects?.first
        if itemDescription.isEmpty {
            itemDescription = anObject?.getDescriptionAsKeyAndValue() ?? []
        }
    }
}

extension ItemDescriptionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        fetchedItemDescriptionController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchedItemDescriptionController.fetchedObjects?.first == nil { return 0 }
        extractDescriptionFromDB()
        return itemDescription.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IconCell", for: indexPath) as! ItemDescriptionIconTableViewCell
            cell.startLoadingAnimation()
            
            dataProvider.retrieveIcon(for: item, forceUpdate: updateCachedImage) { [weak self] image, error in
                self?.updateCachedImage = false
                DispatchQueue.main.async {
                    cell.stopLoadingAnimationAndSetContentImage(image)
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemDescriptionTableViewCell
            cell.updateCellContent(with: dataForCell(at: indexPath)!)
            return cell
        }
    }
}

extension ItemDescriptionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if let data = dataForCell(at: indexPath) {
            let value = data.1
            let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
                let action = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { action in
                    UIPasteboard.general.string = value
                    print("copied '\(value)'")
                }
                return UIMenu(options: .displayInline, children: [action])
            }
            return configuration
        } else {
            return nil
        }
        
    }
}

extension ItemDescriptionViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        extractDescriptionFromDB(anObject)
        tableView.reloadData()
    }
}
