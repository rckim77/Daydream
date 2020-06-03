//
//  Extensions.swift
//  Daydream
//
//  Created by Raymond Kim on 2/25/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

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
        guard let viewport = self.viewport else {
            return nil
        }
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

    /*

     typedef NS_ENUM(NSInteger, GMSPlacesBusinessStatus) {
       /** The business status is not known. */
       GMSPlacesBusinessStatusUnknown,
       /** The business is operational. */
       GMSPlacesBusinessStatusOperational,
       /** The business is closed temporarily. */
       GMSPlacesBusinessStatusClosedTemporarily,
       /** The business is closed permanently. */
       GMSPlacesBusinessStatusClosedPermanently,
     };

     */
    var placeableBusinessStatus: PlaceBusinessStatus? {
        switch self.businessStatus {
        case .operational:
            return .operational
        case .closedTemporarily:
            return .closedTemporarily
        case .closedPermanently:
            return .closedPermanently
        default:
            return nil
        }
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
        searchBar.setPlaceholderColor(.white)

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

    func setAutocompleteFilter(_ type: GMSPlacesAutocompleteTypeFilter) {
        let filter = GMSAutocompleteFilter()
        filter.type = type
        autocompleteFilter = filter
    }
}

extension GMSMapView {
    func configureMapStyle(isDark: Bool) {
        if isDark {
            guard let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") else {
                return
            }
            mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        } else {
            mapStyle = nil
        }
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
        return UIDevice().deviceSize
    }

    var notchHeight: CGFloat {
        // swiftlint:disable discouraged_direct_init
        return UIDevice().notchHeight
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
    func setPlaceholderColor(_ color: UIColor) {
        searchTextField.setPlaceholder(textColor: color)
    }
}

extension UITextField {
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

extension UIButton {
    func configureWithSystemIcon(_ name: String) {
        let heavyConfig = UIImage.SymbolConfiguration(weight: .heavy)
        let largeConfig = UIImage.SymbolConfiguration(scale: .large)
        let symbolConfig = largeConfig.applying(heavyConfig)
        let icon = UIImage(systemName: name)
        setImage(icon, for: .normal)
        setPreferredSymbolConfiguration(symbolConfig, forImageIn: .normal)
        tintColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 0.5
        layer.shadowOpacity = 1
    }
}
