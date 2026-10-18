import GooglePlacesSwift
import SwiftUI

struct MapPlaceDetailCardView: View {
    let state: MapReviewsViewState
    var isViewingDarkMode: Bool
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
                    .frame(maxWidth: .infinity)
                    .padding(16)
                } else {
                    let compactConfig = PlaceDetailsCompactConfiguration(content: PlaceDetailsCompactView.standardContent,
                                                                         theme: PlacesMaterialTheme())
                    PlaceDetailsCompactView(
                        orientation: .horizontal,
                        query: .constant(PlaceDetailsQuery(identifier: .placeID(placeID))),
                        configuration: compactConfig,
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
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            .accessibilityElement(children: .contain)
            .accessibilityValue(state.loadFailed ? "unavailable" : state.hasLoaded ? "loaded" : "loading")
            .accessibilityIdentifier("map-reviews-overlay")
            .environment(\.colorScheme, isViewingDarkMode ? .dark : .light)
        }
    }
}
