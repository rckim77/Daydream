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
        let cancelBtnAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelBtnAttributes, for: .normal)

        // style search bar text color
        let searchBarTextField = self.searchBar.value(forKey: "searchField") as? UITextField
        searchBarTextField?.textColor = .white

        // style placeholder text color
        let placeholderTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        searchBarTextField?.attributedPlaceholder = NSAttributedString(string: "e.g., Tokyo", attributes: placeholderTextAttributes)

        // style search icon
        searchBar.setImage(#imageLiteral(resourceName: "searchIconWhite"), for: .search, state: .normal)

        // style clear text icon
        searchBar.setImage(#imageLiteral(resourceName: "clearIcon"), for: .clear, state: .normal)
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

@IBDesignable
class DesignableView: UIView {
}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let shadowColor = layer.shadowColor {
                layer.shadowColor = shadowColor
            }
            return nil
        }
        set {
            if let shadowColor = newValue {
                layer.shadowColor = shadowColor.cgColor
            }
        }
    }

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

    func addBorder(color: CGColor = UIColor.white.cgColor, width: CGFloat = 1.0) {
        layer.borderWidth = width
        layer.borderColor = color
        layer.cornerRadius = cornerRadius
    }
}

extension UIViewController {
    func add(_ childVC: UIViewController) {
        addChildViewController(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParentViewController: self)
    }

    func remove() {
        guard parent != nil else { return }
        willMove(toParentViewController: nil)
        removeFromParentViewController()
        view.removeFromSuperview()
    }

    func openUrl(_ url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:])
    }
}
