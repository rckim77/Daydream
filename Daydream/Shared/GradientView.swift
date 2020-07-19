//
//  GradientView.swift
//  Daydream
//
//  Created by Raymond Kim on 5/31/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit

/// In order for the gradient layer to display properly, make sure to manually set the gradient layer's
/// frame to the gradient view's bounds (e.g., in a configure() method after gradient view has been added
/// to its superview and constraints have been set).
final class GradientView: UIView {

    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.45).cgColor]
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("Error")
    }
}
