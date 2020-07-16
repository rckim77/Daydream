//
//  CuratedCityCollectionView.swift
//  Daydream
//
//  Created by Ray Kim on 7/15/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit

final class CuratedCityCollectionView: UICollectionView {
    
    private let isSmallDevice: Bool
    private let itemSize: CGSize

    var height: CGFloat {
        contentInset.bottom + itemSize.height
    }
    
    init(isSmallDevice: Bool) {
        self.isSmallDevice = isSmallDevice
        self.itemSize = CGSize(width: 120, height: isSmallDevice ? 130 : 212)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = itemSize
        flowLayout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        
        register(CuratedCityCollectionViewCell.self, forCellWithReuseIdentifier: CuratedCityCollectionViewCell.reuseIdentifier)
        backgroundColor = .clear
        contentInset = UIEdgeInsets(top: 0, left: 12, bottom: isSmallDevice ? 36 : 58, right: 12)
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
