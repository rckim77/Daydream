//
//  GoogleExtensions.swift
//  Daydream
//
//  Created by Raymond Kim on 6/3/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import GooglePlaces
import GoogleMaps

extension GMSAutocompleteResultsViewController {
    func setStyle() {
        tableCellBackgroundColor = UIColor.black.withAlphaComponent(0.3)
        primaryTextHighlightColor = .white
        primaryTextColor = .lightGray
        secondaryTextColor = .lightGray
    }

    func setAutocompleteFilter() {
        let filter = GMSAutocompleteFilter()
        filter.types = ["(cities)"]
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
