//
//  MapViewControllerRepresentable.swift
//  Daydream
//
//  Created by Ray Kim on 10/16/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift

struct MapViewControllerRepresentable: UIViewControllerRepresentable {

    typealias UIViewControllerType = MapViewController
    
    let place: Place
    let isViewingDarkMode: Bool
    let isViewing3D: Bool

    func makeUIViewController(context: Context) -> MapViewController {
        let vc = MapViewController(place: place, isViewingDarkMode: isViewingDarkMode, isViewing3D: isViewing3D)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        uiViewController.isViewingDarkMode = isViewingDarkMode
        uiViewController.isViewing3D = isViewing3D
    }
}
