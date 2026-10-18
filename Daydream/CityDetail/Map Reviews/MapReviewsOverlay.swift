import GooglePlacesSwift
import SwiftUI

/// Google's full component owns review rendering, scrolling and attribution inside the map overlay.
struct MapReviewsOverlay: View {
    let state: MapReviewsViewState
    let onPlaceLoaded: (Place) -> Void

    var body: some View {
        if let placeID = state.placeID {
            let requestID = state.requestID
            Group {
                if state.loadFailed {
                    ViewThatFits(in: .vertical) {
                        VStack(spacing: 12) {
                            Label("Reviews unavailable", systemImage: "exclamationmark.bubble")
                                .labelStyle(.titleAndIcon)
                                .multilineTextAlignment(.center)
                                .accessibilityLabel("Reviews for \(state.placeName) unavailable")
                            Button("Try Again") { state.retry() }
                                .buttonStyle(.bordered)
                                .accessibilityIdentifier("map-reviews-retry")
                        }
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.bubble")
                                .accessibilityHidden(true)
                            Button("Try Again") { state.retry() }
                                .buttonStyle(.bordered)
                                .accessibilityLabel("Retry reviews for \(state.placeName)")
                                .accessibilityIdentifier("map-reviews-retry")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(16)
                } else {
                    GooglePlacesSwift.PlaceDetailsView(
                        query: .constant(PlaceDetailsQuery(identifier: .placeID(placeID))),
                        configuration: PlaceDetailsConfiguration(
                            content: [.name(), .address(), .reviews()],
                            theme: PlacesMaterialTheme()
                        ),
                        placeDetailsCallback: { result in
                            if result.error != nil {
                                state.complete(requestID: requestID, failed: true)
                            } else if let place = result.place,
                                      state.complete(requestID: requestID, failed: false) {
                                onPlaceLoaded(place)
                            }
                        }
                    )
                    .id(requestID)
                    .accessibilityIdentifier("map-reviews-component")
                }
            }
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            .accessibilityElement(children: .contain)
            .accessibilityValue(state.loadFailed ? "unavailable" : state.hasLoaded ? "loaded" : "loading")
            .accessibilityIdentifier("map-reviews-overlay")
        }
    }
}
