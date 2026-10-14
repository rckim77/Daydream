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
    let fadesLeadingEdge: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var placeholderCount: Int {
        horizontalSizeClass == .regular ? 9 : 4
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
        .mask {
            HStack(spacing: 0) {
                LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                    .frame(width: fadesLeadingEdge ? 24 : 0)
                Color.black
            }
        }
        .ignoresSafeArea(.container, edges: .horizontal)
    }
}
