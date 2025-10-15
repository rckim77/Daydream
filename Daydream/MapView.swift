//
//  MapView.swift
//  Daydream
//
//  Created by Ray Kim on 10/15/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift
import MapKit

struct MapView: View {
    
    @Binding var mapPosition: MapCameraPosition
    let place: Place
    
    var body: some View {
        Map(position: $mapPosition) {
            Marker(place.displayName ?? "", coordinate: place.location)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}
