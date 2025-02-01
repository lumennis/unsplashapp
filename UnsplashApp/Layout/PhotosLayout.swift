//
//  PhotosLayout.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//

import UIKit

protocol PhotosLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, cellWidth : CGFloat ) -> CGFloat
    func idForItem(at indexPath: IndexPath) -> String
    func numberOfItems(inSection section: Int) -> Int
}

class PhotosLayout: UICollectionViewLayout {
    
    weak var delegate: PhotosLayoutDelegate?
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 6
    private var cache: [String: UICollectionViewLayoutAttributes] = [:]
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard let collectionView = collectionView,
              let delegate = delegate else { return }
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        guard numberOfItems > 0,
              delegate.numberOfItems(inSection: 0) > 0 else {
            cache.removeAll()
            contentHeight = 0
            return
        }
        
        if !cache.isEmpty && cache.count == numberOfItems {
            return
        }
        
        cache.removeAll()
        contentHeight = 0
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            
            guard item < delegate.numberOfItems(inSection: 0) else { break }
            
            let photoHeight = delegate.collectionView(
                collectionView,
                heightForPhotoAtIndexPath: indexPath,
                cellWidth: columnWidth
            )
            
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(
                x: xOffset[column],
                y: yOffset[column],
                width: columnWidth,
                height: height
            )
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            
            let itemId = delegate.idForItem(at: indexPath)
            cache[itemId] = attributes
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.values.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let itemId = delegate?.idForItem(at: indexPath) else { return nil }
        return cache[itemId]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return newBounds.width != collectionView.bounds.width
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
        contentHeight = 0
    }
}
