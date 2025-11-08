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
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 2) {
                if let reviewSummary = place?.reviewSummary {
                    ReviewSummaryCard(summary: reviewSummary)
                } else if let reviews = place?.reviews {
                    ForEach(reviews, id: \.hashValue) { review in
                        ReviewCard(review: review)
                    }
                }
            }
        }
        .background(.clear)
        .scrollIndicators(.hidden)
        .contentMargins(16)
        .scrollTargetBehavior(.paging)
        .task {
            place = await API.PlaceSearch.fetchPlaceWithReviewsBy(placeId: placeId)
        }
    }
}

#Preview {
    MapReviewsCarousel(placeId: "test")
}
