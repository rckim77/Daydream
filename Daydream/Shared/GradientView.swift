//
//  GradientView.swift
//  Daydream
//
//  Created by Raymond Kim on 5/31/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit

/// In order for the gradient layer to display properly, make sure to call updateFrame() after gradient view
/// has been added to its superview and constraints have been set. Unfortunately, the background
/// color doesn't automatically update when the user changes their light/dark mode.
final class GradientView: UIView {

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = traitCollection.userInterfaceStyle == .dark ? darkColors : colors
        return layer
    }()
    
    private let colors: [CGColor] = [UIColor.clear.cgColor,
                                     UIColor.white.withAlphaComponent(0.4).cgColor,
                                     UIColor.white.withAlphaComponent(0.7).cgColor]
    
    private let darkColors: [CGColor] = [UIColor.clear.cgColor,
                                         UIColor.black.withAlphaComponent(0.4).cgColor,
                                         UIColor.black.withAlphaComponent(0.7).cgColor]

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradientLayer)
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
            if previousTraitCollection.userInterfaceStyle == .light {
                self.gradientLayer.colors = self.darkColors
            } else {
                self.gradientLayer.colors = self.colors
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Error")
    }
    
    func updateFrame() {
        gradientLayer.frame = bounds
    }
}
