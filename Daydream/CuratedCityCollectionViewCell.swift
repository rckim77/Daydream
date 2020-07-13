//
//  CuratedCityCollectionViewCell.swift
//  Daydream
//
//  Created by Ray Kim on 7/13/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit

final class CuratedCityCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addRoundedCorners(radius: 8)
        contentView.backgroundColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
