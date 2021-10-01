//
//  CollectionViewFlowLayout.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 22.09.2021.
//

import Foundation
import UIKit
//Custom collection view flow layout, specifically oriented for iPad
class CollectionViewFlowLayout: UICollectionViewFlowLayout{
    var delegate: FlowLayoutDelegate?
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attributes.isEmpty ? super.layoutAttributesForElements(in: rect) : self.attributes
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        return self.attributes.isEmpty ? super.layoutAttributesForItem(at: indexPath) : self.attributes[indexPath.row]
    }
    open override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        attributes.alpha = 0.75
        
        return attributes
    }
    
    private var attributes: [UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else{
            return
        }
        attributes = []
        let numberOfItemsInLine = self.delegate?.numberOfItemsInLine() ?? 3
        
        for item in 0..<collectionView.numberOfItems(inSection: 0){
            
            let indexPath = IndexPath(row: item, section: 0)
            let sizeForItem = self.delegate?.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? CGSize.zero
            let edgesForCurrentItem =  edgesForItem(collectionView: collectionView, forAnItemAtRow: item)
            
            let bottomEdgeForYPrevious =  edgesForItem(collectionView: collectionView, forAnItemAtRow: item - numberOfItemsInLine).bottom
            
            //Get position for current attributes
            let positionX = item % numberOfItemsInLine == 0 ? edgesForCurrentItem.left : attributes[item - 1].frame.maxX + edgesForCurrentItem.left
            let positionY = item < numberOfItemsInLine ? edgesForCurrentItem.top : attributes[item - numberOfItemsInLine].frame.maxY + bottomEdgeForYPrevious + edgesForCurrentItem.top
            
            
            
            //Create attributes
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: positionX, y: positionY, width: sizeForItem.width, height: sizeForItem.height)
            
            self.attributes.append(attributes)
        }
    }
    
    func  edgesForItem(collectionView: UICollectionView, forAnItemAtRow: Int) -> UIEdgeInsets{
        return self.delegate?.collectionView(collectionView, layout: self, edgesForItemAt: IndexPath(row: max(0, forAnItemAtRow), section: 0)) ?? UIEdgeInsets.zero
    }
}
protocol FlowLayoutDelegate: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, edgesForItemAt indexPath: IndexPath) -> UIEdgeInsets
    func numberOfItemsInLine() -> Int
}

