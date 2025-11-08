//
//  MapReviewsCarousel.swift
//  Daydream
//
//  Created by Ray Kim on 11/6/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import GooglePlacesSwift
import SwiftUI

struct MapReviewsCarousel: View {
    
    let placeId: String
    
    @State private var place: Place?
    
    private var contentMarginOffset: CGFloat {
        place?.reviewSummary != nil ? 0 : 12
    }
    
    private var scrollDisabled: Bool {
        place?.reviewSummary != nil
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                if let reviewSummary = place?.reviewSummary {
                    ReviewSummaryCard(summary: reviewSummary)
                } else if let reviews = place?.reviews {
                    ForEach(reviews, id: \.hashValue) { review in
                        ReviewCard(review: review)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .background(.clear)
        .contentMargins(contentMarginOffset)
        .scrollIndicators(.hidden)
        .scrollDisabled(scrollDisabled)
        .scrollTargetBehavior(.viewAligned)
        .task {
            place = await API.PlaceSearch.fetchPlaceWithReviewsBy(placeId: placeId)
        }
    }
}

#Preview {
    MapReviewsCarousel(placeId: "test")
}
