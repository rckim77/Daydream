//
//  CuratedCityCollectionView.swift
//  Daydream
//
//  Created by Ray Kim on 7/15/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit

final class CuratedCityCollectionView: UICollectionView {
    
    private let deviceSize: UIDevice.DeviceSize
    private let cellHeight: CGFloat

    private var contentInsetBottom: CGFloat {
        deviceSize == .iPhone8 || deviceSize == .iPhoneSE ? 36 : 50
    }
    var height: CGFloat {
        contentInset.bottom + cellHeight
    }
    
    init(deviceSize: UIDevice.DeviceSize) {
        self.deviceSize = deviceSize
        self.cellHeight = deviceSize == .iPhone8 || deviceSize == .iPhoneSE ? 120 : 200
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 120, height: cellHeight)
        flowLayout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        
        register(CuratedCityCollectionViewCell.self, forCellWithReuseIdentifier: CuratedCityCollectionViewCell.reuseIdentifier)
        backgroundColor = .clear
        contentInset = UIEdgeInsets(top: 0, left: 12, bottom: contentInsetBottom, right: 12)
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}