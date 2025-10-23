//
//  CarouselCollectionView.swift
//  Daydream
//
//  Created by Ray Kim on 1/15/24.
//  Copyright © 2024 Raymond Kim. All rights reserved.
//

import UIKit

final class CarouselCollectionView: UICollectionView {

    private var itemSize: CGSize
    private let isIpad: Bool
    private let flowLayout = UICollectionViewFlowLayout()
    private let defaultHeight: CGFloat

    var height: CGFloat {
        contentInset.bottom + itemSize.height
    }
    
    init(deviceSize: UIDevice.DeviceSize, isIpad: Bool) {
        self.isIpad = isIpad
        let width: CGFloat = isIpad ? 200 : 136
        self.defaultHeight = isIpad ? 300 : 240
        self.itemSize = CGSize(width: width, height: defaultHeight)
        
        flowLayout.itemSize = itemSize
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = isIpad ? 20 : 16
        super.init(frame: .zero, collectionViewLayout: flowLayout)

        register(CuratedCityCollectionViewCell.self, forCellWithReuseIdentifier: CuratedCityCollectionViewCell.reuseIdentifier)
        
        backgroundColor = .clear
        let bottomContentInset: CGFloat = deviceSize == .iPhoneSE || deviceSize == .iPhone8 ? 4 : 12
        contentInset = UIEdgeInsets(top: 0, left: 16, bottom: bottomContentInset, right: 16)

        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
