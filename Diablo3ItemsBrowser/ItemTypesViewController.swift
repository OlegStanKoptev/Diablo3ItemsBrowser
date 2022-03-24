//
//  ItemTypesViewController.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 09.03.2022.
//

import UIKit
import Combine

struct Section: Identifiable {
    enum Identifier {
        case main
    }
    
    var id: Identifier
    var itemTypes: [ItemTypeData.ID]
}

struct ItemTypeData: Identifiable {
    var id: String
    
    var name: String
    var itemCount: Int = 0
}

final class ItemTypesViewController: UIViewController {
    var dataSource: UICollectionViewDiffableDataSource<Section.ID, ItemTypeData.ID>! = nil
    var collectionView: UICollectionView!
    
    var sectionsStore: AnyModelStore<Section>
    var itemTypesStore: AnyModelStore<ItemTypeData>
    
    fileprivate var prefetchingIndexPathOperations = [IndexPath: AnyCancellable]()
    
    init(sectionsStore: AnyModelStore<Section>, itemTypesStore: AnyModelStore<ItemTypeData>) {
        self.sectionsStore = sectionsStore
        self.itemTypesStore = itemTypesStore
        
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Diablo 3 Items"
        configureHierarchy()
        configureDataSource()
        setInitialData()
    }
}

extension ItemTypesViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.prefetchDataSource = self
        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ItemTypesCollectionViewCell, ItemTypeData.ID> { [weak self] cell, indexPath, itemTypeID in
            guard let self = self else { return }
            
            let itemType = self.itemTypesStore.fetchByID(itemTypeID)
            
            // TODO: Retrieve items count
            
            cell.updateCellContent(with: itemType)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section.ID, ItemTypeData.ID>(collectionView: collectionView) { (collectionView, indexPath, identifier) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
            
        }
    }
    
    private func setInitialData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID, ItemTypeData.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.sectionsStore.fetchByID(.main).itemTypes, toSection: .main)
        dataSource.apply(snapshot)
    }
}

extension ItemTypesViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
    }
}

extension ItemTypesViewController {
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(350))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(350))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            let sectionID = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            
            section.interGroupSpacing = 20
            
            if sectionID == .main {
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
            }
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider,
            configuration: config
        )
        
        return layout
    }
}
