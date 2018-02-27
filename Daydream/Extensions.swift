//
//  Extensions.swift
//  Daydream
//
//  Created by Raymond Kim on 2/25/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces

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
        tableCellBackgroundColor = UIColor.black.withAlphaComponent(0.1)
        primaryTextHighlightColor = .white
        primaryTextColor = .lightGray
        secondaryTextColor = .lightGray
        
    }
}
