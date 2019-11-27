//
//  Extensions.swift
//  Daydream
//
//  Created by Raymond Kim on 2/25/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces

extension GMSPlace: Placeable {
    var placeableId: String? {
        return self.placeID
    }

    var placeableName: String? {
        return self.name
    }

    var placeableFormattedAddress: String? {
        return self.formattedAddress
    }

    var placeableFormattedPhoneNumber: String? {
        return self.phoneNumber
    }

    var placeableRating: Float? {
        return self.rating
    }

    var placeableCoordinate: CLLocationCoordinate2D {
        return self.coordinate
    }

    var placeableViewport: Viewport? {
        guard let viewport = self.viewport else { return nil }
        return Viewport(northeastLat: viewport.northEast.latitude,
                        northeastLng: viewport.northEast.longitude,
                        southwestLat: viewport.southWest.latitude,
                        southwestLng: viewport.southWest.longitude)
    }

    var placeableMapUrl: String? {
        return nil
    }

    var placeableReviews: [Reviewable]? {
        return nil
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red = CGFloat(r) / 255
        let green = CGFloat(g) / 255
        let blue = CGFloat(b) / 255

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

extension UISearchController {
    func setStyle() {
        // style cancel button
        let cancelBtnAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelBtnAttributes, for: .normal)

        if #available(iOS 13, *) {
            searchBar.searchTextField.textColor = .white
            searchBar.searchTextField.placeholder = "e.g., Tokyo"
            searchBar.setPlaceholderColor(.white)
        } else {
            // style search bar text color
            let searchBarTextField = self.searchBar.value(forKey: "searchField") as? UITextField
            searchBarTextField?.textColor = .white

            // style placeholder text color
            let placeholderTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            searchBarTextField?.attributedPlaceholder = NSAttributedString(string: "e.g., Tokyo", attributes: placeholderTextAttributes)
        }

        // style search icon
        searchBar.setImage(#imageLiteral(resourceName: "searchIconWhite"), for: .search, state: .normal)

        // style clear text icon
        searchBar.setImage(#imageLiteral(resourceName: "clearIcon"), for: .clear, state: .normal)
    }
}

extension UISearchBar {
    func setPlaceholderColor(_ color: UIColor) {
        searchTextField.setPlaceholder(textColor: color)
    }
}

extension UITextField {
    private class Label: UILabel {
        private var _textColor: UIColor = .lightGray

        override var textColor: UIColor! {
            get { return _textColor }
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

    var placeholderLabel: UILabel? {
        return value(forKey: "placeholderLabel") as? UILabel
    }

    func setPlaceholder(textColor: UIColor) {
        guard let placeholderLabel = placeholderLabel else {
            return
        }

        let label = Label(label: placeholderLabel, textColor: textColor)
        setValue(label, forKey: "placeholderLabel")
    }
}

extension GMSAutocompleteResultsViewController {
    func setStyle() {
        tableCellBackgroundColor = UIColor.black.withAlphaComponent(0.3)
        primaryTextHighlightColor = .white
        primaryTextColor = .lightGray
        secondaryTextColor = .lightGray
    }
}

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
                                      cornerRadii: CGSize(width: 10, height: 10)).cgPath

        layer.mask = rectShape
    }

    func addTopRoundedCorners() {
        let rectShape = CAShapeLayer()
        rectShape.bounds = frame
        rectShape.position = center
        rectShape.path = UIBezierPath(roundedRect: bounds,
                                      byRoundingCorners: [.topLeft, .topRight],
                                      cornerRadii: CGSize(width: 10, height: 10)).cgPath

        layer.mask = rectShape
    }

    func addBorder(color: UIColor = .white, width: CGFloat = 1.0) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
}

extension UIViewController {

    var deviceSize: UIDevice.DeviceSize {
        // swiftlint:disable discouraged_direct_init
        return UIDevice().deviceSize
    }

    var notchHeight: CGFloat {
        // swiftlint:disable discouraged_direct_init
        return UIDevice().notchHeight
    }

    var hasNotch: Bool {
        // swiftlint:disable discouraged_direct_init
        return UIDevice().hasNotch
    }

    func add(_ childVC: UIViewController) {
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }

    func openUrl(_ url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:])
    }
}

extension String {
    var abbreviated: String {
        let nameParts = self.components(separatedBy: " ")
        guard let first = nameParts.first, let lastInitial = nameParts.last?.first else { return self }
        return first + " " + String(lastInitial) + "."
    }
}
