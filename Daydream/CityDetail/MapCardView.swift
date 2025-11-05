//
//  MapCardView.swift
//  Daydream
//
//  Created by Ray Kim on 10/15/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift
import MapKit

struct MapCardView: View {
    
    @Binding var mapPosition: MapCameraPosition
    let place: Place
    
    private var placeLocation: CLLocation {
        CLLocation(latitude: place.location.latitude, longitude: place.location.longitude)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $mapPosition) {
                Marker(place.displayName ?? "", coordinate: place.location)
            }
            Button {
                if let address = place.displayName {
                    let item: MKMapItem
                    
                    if #available(iOS 26, *) {
                        item = MKMapItem(location: placeLocation, address: nil)
                    } else {
                        let placemark = MKPlacemark(coordinate: place.location)
                        item = MKMapItem(placemark: placemark)
                    }
                    
                    item.name = address
                    MKMapItem.openMaps(with: [item])
                }
            } label: {
                Image(systemName: "arrow.up.right.circle")
            }
            .foregroundStyle(.primary)
            .padding(8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}
