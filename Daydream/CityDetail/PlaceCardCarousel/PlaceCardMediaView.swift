import Foundation
import GooglePlacesSwift
import SwiftUI

struct PlaceCardMediaView: View {
    let placeID: String
    let width: CGFloat
    let placeName: String
    let onViewMap: () -> Void
    @State private var requestID = UUID()
    @State private var loadFailed = false
    @State private var hasLoaded = false

    var body: some View {
        let currentRequest = requestID
        Group {
            if loadFailed {
                VStack(spacing: 12) {
                    Label("Photo unavailable", systemImage: "photo")
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        loadFailed = false
                        hasLoaded = false
                        requestID = UUID()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                let theme: PlacesMaterialTheme = {
                    var theme = PlacesMaterialTheme()
                    theme.font.titleSmall = .headline
                    theme.font.bodySmall = .headline
                    return theme
                }()
                let compactConfig = AdvancedPlaceDetailsCompactConfiguration(
                    content: [.media(), .name(), .price()],
                    theme: theme
                )
                AdvancedPlaceDetailsCompactView(
                    query: .constant(PlaceDetailsQuery(identifier: .placeID(placeID))),
                    configuration: compactConfig,
                    placeDetailsCallback: { result in
                        guard requestID == currentRequest else { return }
                        loadFailed = result.error != nil
                        hasLoaded = result.place != nil && result.error == nil
                    }
                )
                .cornerActions { _ in [] }
                .mainActions { _ in [] }
                .frame(width: width)
                .id(requestID)
                .contentShape(RoundedRectangle(cornerRadius: 16))
                .onTapGesture(perform: onViewMap)
                .accessibilityAction(named: "View map and reviews", onViewMap)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onViewMap) {
                Image(systemName: "map")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .circle)
            .accessibilityLabel("Map and reviews for \(placeName)")
            .accessibilityIdentifier("place-card-\(placeID)")
            .padding(12)
        }
        .accessibilityElement(children: .contain)
        .accessibilityValue(loadFailed ? "unavailable" : hasLoaded ? "loaded" : "loading")
        .accessibilityIdentifier("place-media-\(placeID)")
    }
}
