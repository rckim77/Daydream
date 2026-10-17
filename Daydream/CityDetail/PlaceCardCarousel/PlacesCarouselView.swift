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
    var expandsCards = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let contentMargin: CGFloat = 24
    
    private var placeholderCount: Int {
        horizontalSizeClass == .regular ? 9 : 4
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 16) {
                if places.isEmpty {
                    ForEach(1...placeholderCount, id: \.self) { _ in
                        PlaceCardView(place: nil, tappedPlace: $tappedPlace, expandsToFillHeight: expandsCards)
                    }
                } else {
                    ForEach(places, id: \.placeID) { place in
                        PlaceCardView(place: place, tappedPlace: $tappedPlace, expandsToFillHeight: expandsCards)
                    }
                }
            }
        }
        .contentMargins(contentMargin, for: .scrollContent)
        .frame(
            minHeight: expandsCards ? PlaceCardView.minimumHeight + contentMargin * 2 : nil,
            maxHeight: expandsCards ? .infinity : nil
        )
        .mask {
            HStack(spacing: 0) {
                LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                    .frame(width: fadesLeadingEdge ? contentMargin : 0)
                Color.black
            }
        }
        .ignoresSafeArea(.container, edges: .horizontal)
    }
}
