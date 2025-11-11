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
    
    private var placeholderCount: Int {
        isIpad ? 9 : 4
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                if places.isEmpty {
                    ForEach(1...placeholderCount, id: \.self) { _ in
                        PlaceCardView(place: nil, tappedPlace: $tappedPlace)
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
