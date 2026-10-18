import Foundation
import GooglePlacesSwift
import SwiftUI

/// Let the supported component own the photo, its attribution and media request lifetime.
struct PlaceCardMediaView: View {
    let placeID: String
    let width: CGFloat
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
                GooglePlacesSwift.PlaceDetailsCompactView(
                    query: .constant(PlaceDetailsQuery(identifier: .placeID(placeID))),
                    configuration: PlaceDetailsCompactConfiguration(
                        content: [.media(lightbox: false), .name(), .price()],
                        theme: PlacesMaterialTheme()
                    ),
                    placeDetailsCallback: { result in
                        guard requestID == currentRequest else { return }
                        loadFailed = result.error != nil
                        hasLoaded = result.place != nil && result.error == nil
                    }
                )
                .frame(width: width)
                .id(requestID)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityValue(loadFailed ? "unavailable" : hasLoaded ? "loaded" : "loading")
        .accessibilityIdentifier("place-media-\(placeID)")
    }
}
