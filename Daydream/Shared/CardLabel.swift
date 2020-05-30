//
//  CardLabel.swift
//  Daydream
//
//  Created by Raymond Kim on 5/30/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit

/// Used on search detail screen for main labels in each point of interest or eatery cell.
final class CardLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = .white
        font = UIFont.preferredFont(forTextStyle: .title2)
        adjustsFontForContentSizeCategory = true
        shadowColor = .black
        shadowOffset = CGSize(width: 0, height: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("Error")
    }
}
