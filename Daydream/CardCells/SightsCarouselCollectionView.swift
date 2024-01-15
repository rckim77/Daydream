//
//  SightsCarouselCollectionView.swift
//  Daydream
//
//  Created by Ray Kim on 1/15/24.
//  Copyright © 2024 Raymond Kim. All rights reserved.
//

import UIKit

final class SightsCarouselCollectionView: UICollectionView {

    private var itemSize: CGSize
    private let isIpad: Bool
    private let flowLayout = UICollectionViewFlowLayout()
    private let defaultHeight: CGFloat
    private let defaultContentInsetBottom: CGFloat

    var height: CGFloat {
        contentInset.bottom + itemSize.height
    }
    
    init(deviceSize: UIDevice.DeviceSize, isIpad: Bool) {
        self.isIpad = isIpad
        let isSmallDevice = deviceSize == .iPhoneSE || deviceSize == .iPhone8
        let width: CGFloat = isIpad ? 180 : 120
        self.defaultHeight = isIpad ? 280 : isSmallDevice ? 130 : 212
        self.itemSize = CGSize(width: width, height: defaultHeight)
        self.defaultContentInsetBottom = isIpad ? 80 : isSmallDevice ? 36 : 58
        
        flowLayout.itemSize = itemSize
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = isIpad ? 18 : 10
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        
        register(SightsCarouselCardCell.self, forCellWithReuseIdentifier: SightsCarouselCardCell.reuseIdentifier)
        backgroundColor = .clear
        let contentInsetHorizontal: CGFloat = isIpad ? 18 : 12
        contentInset = UIEdgeInsets(top: 0, left: contentInsetHorizontal, bottom: defaultContentInsetBottom, right: contentInsetHorizontal)
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateItemSizeForOrientationChange() {
        let isLandscapeIpad = UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .landscapeLeft && isIpad
        flowLayout.itemSize.height = isLandscapeIpad ? 220 : defaultHeight
        contentInset.bottom = isLandscapeIpad ? 24 : defaultContentInsetBottom
    }
}
