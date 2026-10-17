import SwiftUI

struct MapPlaceDetailsSheet: View {
    @ObservedObject var context: MapReviewContext
    let onRetry: () -> Void
    let onOpenMaps: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(context.selectedName)
                        .font(.title).bold()
                        .accessibilityAddTraits(.isHeader)
                    if let address = context.place?.formattedAddress {
                        Text(address)
                            .accessibilityIdentifier("map-place-address")
                    }
                    if context.isLoading {
                        ProgressView("Loading place details")
                    } else if context.loadFailed {
                        Text("Couldn't load place details.")
                        Button("Try Again", action: onRetry)
                    } else if let summary = context.displayedReviewSummary {
                        ReviewSummaryCard(summary: summary)
                    } else if let reviews = context.place?.reviews, !reviews.isEmpty {
                        ForEach(reviews, id: \.hashValue) { review in
                            ReviewCard(review: review, showsFullText: true)
                        }
                    } else {
                        Text("No reviews are available for this place.")
                    }
                    Button("Open in Google Maps", systemImage: "arrow.up.right", action: onOpenMaps)
                        .labelStyle(.titleAndIcon)
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("map-place-open-maps")
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 700, alignment: .leading)
                .frame(maxWidth: .infinity)
                .padding(20)
            }
            .accessibilityIdentifier("map-place-details-scroll")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("map-place-details-close")
                }
            }
        }
    }
}
