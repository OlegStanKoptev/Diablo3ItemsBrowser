//
//  MosaicLayout.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import UIKit

enum CellSize {
    case small
    case large
}

enum MosaicSegmentStyle {
    case threeSmall
    case oneLargeTwoSmall
    case twoLargeOneSmall
    case threeLarge
}

class MosaicLayout: UICollectionViewLayout {
    var sizesStorage: [Int: CellSize] = [:]
    private var contentBounds = CGRect.zero
    private var cachedAttributes = [UICollectionViewLayoutAttributes]()
    private let horizontalPadding: CGFloat = 16
    private let itemPadding: CGFloat = 4
    
    /// - Tag: PrepareMosaicLayout
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
        
        let count = collectionView.numberOfItems(inSection: 0)
        
        var currentIndex = 0
        var segment: MosaicSegmentStyle = .threeSmall
        var lastFrame: CGRect = .zero
        
        let cvWidth = collectionView.bounds.size.width - horizontalPadding * 2
        
        let largeHeight = cvWidth / 3
        let smallHeight = largeHeight / 2
        
        while currentIndex < count {
            // 1. determine segment type
            var cellSizes = (currentIndex..<currentIndex+3)
                .map { (index: $0, size: sizesStorage[$0, default: .small]) }
            cellSizes.sort { $0.size == .large && $1.size == .small }
            let largeQnt = cellSizes.reduce(0, { $0 + ($1.size == .large ? 1 : 0) })
            var segmentHeight: CGFloat = 0
            switch largeQnt {
            case 0:
                segment = .threeSmall
                segmentHeight = largeHeight
            case 1:
                segment = .oneLargeTwoSmall
                segmentHeight = largeHeight
            case 2:
                segment = .twoLargeOneSmall
                segmentHeight = largeHeight + smallHeight
            case 3:
                segment = .threeLarge
                segmentHeight = largeHeight + largeHeight
            default:
                fatalError()
            }
            
            // 2. create frame
            let segmentFrame = CGRect(x: horizontalPadding, y: lastFrame.maxY + 1.0, width: cvWidth, height: segmentHeight)
            
            // 3. separate items according to segment type
            var segmentRects = [CGRect]()
            switch segment {
            case .threeSmall:
                let verticalSlice1 = segmentFrame.dividedIntegral(fraction: 0.33, from: .minXEdge)
                let verticalSlice2 = verticalSlice1.second.dividedIntegral(fraction: 0.5, from: .minXEdge)
                segmentRects = [verticalSlice1.first, verticalSlice2.first, verticalSlice2.second]
            case .oneLargeTwoSmall:
                let verticalSlice = segmentFrame.dividedIntegral(fraction: 0.5, from: .minXEdge)
                let horizontalSlice = verticalSlice.second.dividedIntegral(fraction: 0.5, from: .minYEdge)
                segmentRects = [verticalSlice.first, horizontalSlice.first, horizontalSlice.second]
            case .twoLargeOneSmall:
                let horizontalSlice = segmentFrame.dividedIntegral(fraction: 0.66, from: .minYEdge)
                let verticalSlice = horizontalSlice.first.dividedIntegral(fraction: 0.5, from: .minXEdge)
                segmentRects = [verticalSlice.first, verticalSlice.second, horizontalSlice.second]
            case .threeLarge:
                let horizontalSlice = segmentFrame.dividedIntegral(fraction: 0.5, from: .minYEdge)
                let verticalSlice = horizontalSlice.first.dividedIntegral(fraction: 0.5, from: .minXEdge)
                segmentRects = [verticalSlice.first, verticalSlice.second, horizontalSlice.second]
            }
            
            var newAttributes: [(index: Int, attributes: UICollectionViewLayoutAttributes)] = []
            for (n, (cellIndex, _)) in cellSizes.enumerated() {
                let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: cellIndex, section: 0))
                let rect = segmentRects[n]
                attributes.frame = CGRect(x: rect.minX + itemPadding, y: rect.minY + itemPadding, width: rect.width - itemPadding * 2, height: rect.height - itemPadding * 2)
                
                
                newAttributes.append((cellIndex, attributes))
                
                contentBounds = contentBounds.union(lastFrame)
                
                currentIndex += 1
                lastFrame = segmentRects[n]
            }
            
            cachedAttributes.append(contentsOf: newAttributes.sorted { $0.index < $1.index }.map { $0.attributes })
            
            if (currentIndex > count) {
                cachedAttributes.removeLast(currentIndex - count)
            }
            
            contentBounds = contentBounds.union(lastFrame)
        }
    }
    
    /// - Tag: CollectionViewContentSize
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    /// - Tag: ShouldInvalidateLayout
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    /// - Tag: LayoutAttributesForItem
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    /// - Tag: LayoutAttributesForElements
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        // Find any cell that sits within the query rect.
        guard let lastIndex = cachedAttributes.indices.last,
              let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else { return attributesArray }
        
        // Starting from the match, loop up and down through the array until all the attributes
        // have been added within the query rect.
        for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            attributesArray.append(attributes)
        }
        
        for attributes in cachedAttributes[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            attributesArray.append(attributes)
        }
        
        return attributesArray
    }
    
    // Perform a binary search on the cached attributes array.
    func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }
        
        let mid = (start + end) / 2
        let attr = cachedAttributes[mid]
        
        if attr.frame.intersects(rect) {
            return mid
        } else {
            if attr.frame.maxY < rect.minY {
                return binSearch(rect, start: (mid + 1), end: end)
            } else {
                return binSearch(rect, start: start, end: (mid - 1))
            }
        }
    }
    
}

