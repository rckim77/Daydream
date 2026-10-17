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
    /// A nil height lets the map fill the expanded column below the city summary.
    var height: CGFloat? = 190
    @AppStorage("reviewsViewedCount") private var reviewsViewedCount: Int = 0
    
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
                    let item = MKMapItem(location: placeLocation, address: nil)
                    item.name = address
                    MKMapItem.openMaps(with: [item])
                }
            } label: {
                Image(systemName: "arrow.up.right.circle")
            }
            .accessibilityLabel("Open in Maps")
            .frame(minWidth: 44, minHeight: 44)
            .foregroundStyle(.primary)
            .padding(8)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: height ?? 190, idealHeight: height ?? 340, maxHeight: height == nil ? .infinity : height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
        .padding(.top, 16)
        // Match the carousel's bottom content margin so the visible card edges align.
        .padding(.bottom, height == nil ? 24 : 16)
        .onAppear {
            reviewsViewedCount += 1
        }
    }
}
