//
//  ItemTypesViewController+DataSource.swift
//  Diablo3ItemsBrowser
//
//  Created by Коптев Олег Станиславович on 24.03.2022.
//

import UIKit

extension ItemTypesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedItemTypesController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemTypesCollectionViewCell.identifier, for: indexPath) as! ItemTypesCollectionViewCell

        let itemType = fetchedItemTypesController.object(at: indexPath)
        cell.updateCellContent(with: itemType, highlighted: highlightedCellPath == indexPath)
        
        if itemType.areItemsNotLoaded {
            dataProvider.retrieveItemsCount(for: itemType) { [weak self] itemType, _ in
                guard let self = self else { return }
                self.sizesStorage[indexPath.item] = itemType.itemsCount > self.cellSizeDeterminator ? .large : .small
            }
        }

        return cell
    }
}

extension ItemTypesViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let itemTypes = indexPaths.map { ($0.item, fetchedItemTypesController.object(at: $0)) }
        itemTypes.forEach { index, itemType in
            if itemType.areItemsNotLoaded {
                dataProvider.retrieveItemsCount(for: itemType) { [weak self] itemType, error in
                    guard let self = self else { return }
                    self.sizesStorage[index] = itemType.itemsCount > self.cellSizeDeterminator ? .large : .small
                }
            }
        }
    }
}
