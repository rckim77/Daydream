import GooglePlacesSwift
import SwiftUI

struct MapReviewsCarousel: View {
    @ObservedObject var context: MapReviewContext
    var onRetry: () -> Void = {}
    var onOpenMaps: () -> Void = {}
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            MapAccessiblePlaceDetailsView(context: context, onRetry: onRetry, onOpenMaps: onOpenMaps)
        } else if context.loadFailed {
            VStack(spacing: 12) {
                Text("Couldn't load place details.")
                Button("Try Again", action: onRetry)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background, in: RoundedRectangle(cornerRadius: 16))
            .padding(12)
        } else if let summary = context.displayedReviewSummary {
            ReviewSummaryCard(summary: summary, scrollsText: true)
        } else {
            ScrollView(.horizontal) {
                HStack(spacing: 4) {
                    if let reviews = context.place?.reviews {
                        ForEach(reviews, id: \.hashValue) { review in
                            ReviewCard(review: review)
                                .containerRelativeFrame(.horizontal)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(12)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

#Preview {
    MapReviewsCarousel(context: MapReviewContext(place: nil))
}
