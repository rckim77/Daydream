//
//  CuratedCityCollectionViewCell.swift
//  Daydream
//
//  Created by Ray Kim on 7/13/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit

final class CuratedCityCollectionViewCell: UICollectionViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    static let reuseIdentifier = "curatedCitiesCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addRoundedCorners(radius: 8)
        contentView.backgroundColor = .lightGray
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        // todo
        titleLabel.text = "Bangkok"
    }
}
