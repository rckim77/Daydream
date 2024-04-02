//
//  Extensions.swift
//  Daydream
//
//  Created by Raymond Kim on 2/25/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import CoreLocation

extension UIView {
    func addRoundedCorners(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    func addBottomRoundedCorners() {
        let rectShape = CAShapeLayer()
        rectShape.bounds = frame
        rectShape.position = center
        rectShape.path = UIBezierPath(roundedRect: bounds,
                                      byRoundingCorners: [.bottomLeft, .bottomRight],
                                      cornerRadii: CGSize(width: 16, height: 16)).cgPath

        layer.mask = rectShape
    }

    func addTopRoundedCorners() {
        let rectShape = CAShapeLayer()
        rectShape.bounds = frame
        rectShape.position = center
        rectShape.path = UIBezierPath(roundedRect: bounds,
                                      byRoundingCorners: [.topLeft, .topRight],
                                      cornerRadii: CGSize(width: 16, height: 16)).cgPath

        layer.mask = rectShape
    }

    func addBorder(color: UIColor = .white, width: CGFloat = 1.0) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }

    func addShadow(opacity: Float = 1, offset: CGSize = .zero, radius: CGFloat = 1) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }

    /// This is called when the pointer moves over the button.
    @available(iOS 13.4, *)
    func buttonProvider(button: UIButton, pointerEffect: UIPointerEffect, pointerShape: UIPointerShape) -> UIPointerStyle? {
        let targetedPreview = pointerEffect.preview
        let buttonPointerEffect = UIPointerEffect.highlight(targetedPreview)
        let buttonPointerStyle = UIPointerStyle(effect: buttonPointerEffect, shape: pointerShape)
        return buttonPointerStyle
    }
}

extension UIViewController {

    var deviceSize: UIDevice.DeviceSize {
        // swiftlint:disable discouraged_direct_init
        UIDevice().deviceSize
    }
    
    var isSmallDevice: Bool {
        // swiftlint:disable discouraged_direct_init
        UIDevice().isSmallDevice
    }

    var notchHeight: CGFloat {
        // swiftlint:disable discouraged_direct_init
        UIDevice().notchHeight
    }

    func add(_ childVC: UIViewController) {
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }

    func openUrl(_ url: String) {
        guard let url = URL(string: url) else {
            return
        }
        UIApplication.shared.open(url, options: [:])
    }

    /// This is called when the pointer moves over the button.
    @available(iOS 13.4, *)
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

extension UISearchBar {
    /// DEPRECATED
    func setPlaceholderColor(_ color: UIColor) {
        searchTextField.setPlaceholder(textColor: color)
    }
}

extension UITextField {
    /// DEPRECATED
    private class Label: UILabel {
        private var _textColor: UIColor = .lightGray

        override var textColor: UIColor! {
            get { return _textColor }
            // swiftlint:disable unused_setter_value
            set { super.textColor = _textColor }
        }

        init(label: UILabel, textColor: UIColor) {
            _textColor = textColor
            super.init(frame: label.frame)
            self.text = label.text
            self.font = label.font
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
    }

    /// DEPRECATED
    var placeholderLabel: UILabel? {
        return value(forKey: "placeholderLabel") as? UILabel
    }

    /// DEPRECATED
    func setPlaceholder(textColor: UIColor) {
        guard let placeholderLabel = placeholderLabel else {
            return
        }

        let label = Label(label: placeholderLabel, textColor: textColor)
        setValue(label, forKey: "placeholderLabel")
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
        let heavyConfig = UIImage.SymbolConfiguration(weight: .heavy)
        let textStyle: UIFont.TextStyle = .body
        let scalingConfig = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: textStyle), scale: .large)
        let symbolConfig = scalingConfig.applying(heavyConfig)
        image = UIImage(systemName: name, withConfiguration: symbolConfig)
        baseForegroundColor = .white
    }
}

extension UISearchController {
    func setStyle() {
        // style cancel button
        let cancelBtnAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelBtnAttributes, for: .normal)

        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.placeholder = "e.g., Tokyo"
        searchBar.searchBarStyle = .minimal
        
        // Once we drop iOS 13, we can remove our UITextField extension hack
        if #available(iOS 14.0, *) {
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "e.g., Tokyo",
                                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        } else {
            searchBar.setPlaceholderColor(.white)
        }

        // style search icon
        searchBar.setImage(#imageLiteral(resourceName: "searchIconWhite"), for: .search, state: .normal)

        // style clear text icon
        searchBar.setImage(#imageLiteral(resourceName: "clearIcon"), for: .clear, state: .normal)
    }
}

extension CLLocationCoordinate2D: Equatable {}

public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude)
}
