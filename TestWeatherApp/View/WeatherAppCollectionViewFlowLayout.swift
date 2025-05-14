//
//  WeatherAppCollectionViewFlowLayout.swift
//  TestWeatherApp
//
//  Created by user on 14.05.2025.
//

import UIKit

/// Управление лей-аутом для экрана погоды.
final class WeatherAppCollectionViewFlowLayout: UICollectionViewFlowLayout {
    let shouldDisplayBorder: (UICollectionView, /*section*/Int) -> Bool
    
    init(shouldDisplayBorder: @escaping (UICollectionView, Int) -> Bool) {
        self.shouldDisplayBorder = shouldDisplayBorder
        
        super.init()
        
        self.register(decorationViewClass: WeatherAppSectionDecoratorView.self)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        guard let collectionView = self.collectionView else { return superAttributes }
        
        let layoutFrame = collectionView.readableContentGuide.layoutFrame
        let minX = layoutFrame.minX
        let layoutWidth = layoutFrame.width
        
        let sectionRects = superAttributes.reduce(into: [Int: CGRect]()) { (partial, attributes) in
            let section = attributes.indexPath.section
            if self.shouldDisplayBorder(collectionView, section) {
                let representedElementCategory = attributes.representedElementCategory
                let isCell = representedElementCategory == .cell
                let isHeader = representedElementCategory == .supplementaryView && attributes.representedElementKind == UICollectionView.elementKindSectionHeader
                
                if isCell || isHeader {
                    var frame = attributes.frame
                    frame.origin.x = minX
                    frame.size.width = layoutWidth
                    if let initialRect = partial[section] {
                        partial[section] = initialRect.union(frame)
                    } else {
                        partial[section] = frame
                    }
                }
            }
        }
        let backgroundAttributes = sectionRects.compactMap { (pair) -> UICollectionViewLayoutAttributes? in
            let section = pair.key
            let rect = pair.value
            
            if let backgroundAttribute = self.layoutAttributesForDecorationView(ofKind: String(describing: WeatherAppSectionDecoratorView.self),
                                                                                at: IndexPath(item: 0, section: section)) {
                backgroundAttribute.zIndex = -100
                backgroundAttribute.frame = rect
                return backgroundAttribute
            } else {
                return nil
            }
        }
        return backgroundAttributes + superAttributes
    }
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributesForDecorationView = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
        layoutAttributesForDecorationView.zIndex = -100
        
        return layoutAttributesForDecorationView
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    override func indexPathsToDeleteForDecorationView(ofKind elementKind: String) -> [IndexPath] {
        guard let collectionView = self.collectionView else { return [] }
        
        return (0..<collectionView.numberOfSections).map({ IndexPath(item: 0, section: $0) })
    }
}

final class WeatherAppSectionDecoratorView: UICollectionReusableView {
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.cornerRadius = 12
        self.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        self.superview?.sendSubviewToBack(self)
    }
}
