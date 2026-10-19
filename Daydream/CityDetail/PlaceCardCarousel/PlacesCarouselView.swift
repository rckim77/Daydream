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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var viewportWidth: CGFloat = 0
    private let contentMargin: CGFloat = 24
    private let topContentMargin: CGFloat = 16
    
    private var placeholderCount: Int {
        horizontalSizeClass == .regular ? 9 : 4
    }

    var body: some View {
        let available = max(210, viewportWidth - contentMargin * 2)
        let cardWidth = dynamicTypeSize.isAccessibilitySize
            ? min(420, available)
            : expandsCards ? min(300, max(210, available * 0.55)) : 210
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                if places.isEmpty {
                    ForEach(1...placeholderCount, id: \.self) { _ in
                        PlaceCardView(place: nil, tappedPlace: $tappedPlace, width: cardWidth)
                    }
                } else {
                    ForEach(places, id: \.placeID) { place in
                        PlaceCardView(place: place, tappedPlace: $tappedPlace, width: cardWidth)
                    }
                }
            }
        }
        .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { viewportWidth = $0 }
        .contentMargins(.horizontal, contentMargin, for: .scrollContent)
        .contentMargins(.top, topContentMargin, for: .scrollContent)
        .contentMargins(.bottom, contentMargin, for: .scrollContent)
        .frame(
            minHeight: expandsCards ? PlaceCardView.minimumHeight + topContentMargin + contentMargin : nil,
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
