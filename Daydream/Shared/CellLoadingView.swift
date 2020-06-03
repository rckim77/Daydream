//
//  CellLoadingView.swift
//  Daydream
//
//  Created by Raymond Kim on 5/31/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit

final class CellLoadingView: UIView {

    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
