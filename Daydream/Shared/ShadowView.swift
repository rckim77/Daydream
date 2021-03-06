//
//  ShadowView.swift
//  Daydream
//
//  Created by Raymond Kim on 2/27/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    private let cornerRadius: CGFloat

    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    init(cornerRadius: CGFloat = 8) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupShadow() {
        layer.cornerRadius = cornerRadius
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.4
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                        byRoundingCorners: .allCorners,
                                        cornerRadii: size).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

}
