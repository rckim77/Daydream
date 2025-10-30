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

    func makeUIViewController(context: Context) -> MapViewController {
        let vc = MapViewController(place: place)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        //
    }
}
