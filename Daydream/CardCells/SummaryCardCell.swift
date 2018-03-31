//
//  SummaryCardCell.swift
//  Daydream
//
//  Created by Raymond Kim on 3/31/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit

class SummaryCardCell: UITableViewCell {
    
    @IBOutlet weak var cardView: DesignableView! {
        didSet {
            hero.id = "summaryCard"
        }
    }
    @IBOutlet weak var summaryLabel: UILabel!

    override func setNeedsLayout() {
        super.setNeedsLayout()


        layoutIfNeeded()
    }
}
