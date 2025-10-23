//
//  Extensions.swift
//  Daydream
//
//  Created by Raymond Kim on 2/25/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftUI

extension UIView {
    func addRoundedCorners(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    func addShadow(opacity: Float = 1, offset: CGSize = .zero, radius: CGFloat = 1) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }

    /// This is called when the pointer moves over the button.
    func buttonProvider(button: UIButton, pointerEffect: UIPointerEffect, pointerShape: UIPointerShape) -> UIPointerStyle? {
        let targetedPreview = pointerEffect.preview
        let buttonPointerEffect = UIPointerEffect.highlight(targetedPreview)
        let buttonPointerStyle = UIPointerStyle(effect: buttonPointerEffect, shape: pointerShape)
        return buttonPointerStyle
    }
}

extension UIViewController {
    
    var isSmallDevice: Bool {
        // swiftlint:disable discouraged_direct_init
        UIDevice().isSmallDevice
    }

    func openUrl(_ url: String) {
        guard let url = URL(string: url) else {
            return
        }
        UIApplication.shared.open(url, options: [:])
    }

    /// This is called when the pointer moves over the button.
    func buttonProvider(button: UIButton, pointerEffect: UIPointerEffect, pointerShape: UIPointerShape) -> UIPointerStyle? {
        let targetedPreview = pointerEffect.preview
        let buttonPointerEffect = UIPointerEffect.highlight(targetedPreview)
        let buttonPointerStyle = UIPointerStyle(effect: buttonPointerEffect, shape: pointerShape)
        return buttonPointerStyle
    }

    /// Present a simple alert modal with informational text and a dismiss button. The default text
    /// for the dismiss button is "Got it".
    func presentInfoAlertModal(title: String, message: String?, dismissText: String = "Got it") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dismissText, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension String {
    var abbreviated: String {
        let nameParts = self.components(separatedBy: " ")
        guard let first = nameParts.first, let lastInitial = nameParts.last?.first else {
            return self
        }
        return first + " " + String(lastInitial) + "."
    }
}

extension UIButton {
    func addDropShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 0.5
        layer.shadowOpacity = 1
    }
}

extension UIButton.Configuration {
    mutating func configureForIcon(_ name: String) {
        if #available(iOS 26, *) {
            image = UIImage(systemName: name)
            imagePadding = 4
        } else {
            let heavyConfig = UIImage.SymbolConfiguration(weight: .heavy)
            let textStyle: UIFont.TextStyle = .body
            let scalingConfig = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: textStyle), scale: .large)
            let symbolConfig = scalingConfig.applying(heavyConfig)
            image = UIImage(systemName: name, withConfiguration: symbolConfig)
            baseForegroundColor = .white
        }
    }
}

extension View {
    var isIpad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
}
