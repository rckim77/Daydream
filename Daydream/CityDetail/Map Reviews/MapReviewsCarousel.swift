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
    
    @ObservedObject var context: MapReviewContext
    
    private var contentMarginOffset: CGFloat {
        context.place?.reviewSummary != nil ? 0 : 12
    }
    
    private var scrollDisabled: Bool {
        context.place?.reviewSummary != nil
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                if let reviewSummary = context.place?.reviewSummary {
                    ReviewSummaryCard(summary: reviewSummary)
                } else if let reviews = context.place?.reviews {
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
    }
}

#Preview {
    MapReviewsCarousel(context: MapReviewContext(place: nil))
}
