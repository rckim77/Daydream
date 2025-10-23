//
//  GoogleExtensions.swift
//  Daydream
//
//  Created by Raymond Kim on 6/3/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import GoogleMaps

extension GMSMapView {
    func configureMapStyle(isDark: Bool) {
        self.overrideUserInterfaceStyle = isDark ? .dark : .light
    }
}
