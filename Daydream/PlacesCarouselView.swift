//
//  PlacesCarouselView.swift
//  Daydream
//
//  Created by Ray Kim on 10/15/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift

struct PlacesCarouselView: View {
    
    let places: [Place]
    @Binding var tappedPlace: IdentifiablePlace?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                if places.isEmpty {
                    if isIpad {
                        ForEach(0..<10) {_ in
                            PlaceCardView(place: nil, tappedPlace: $tappedPlace)
                        }
                    } else {
                        ForEach(0..<3) {_ in
                            PlaceCardView(place: nil, tappedPlace: $tappedPlace)
                        }
                    }
                } else {
                    ForEach(places, id: \.placeID) { place in
                        PlaceCardView(place: place, tappedPlace: $tappedPlace)
                    }
                }
            }
        }
        .contentMargins(24, for: .scrollContent)
    }
}
