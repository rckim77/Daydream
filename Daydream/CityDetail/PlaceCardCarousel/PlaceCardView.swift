import GooglePlacesSwift
import SwiftUI

struct PlaceCardView: View {
    /// When this is nil, preserve a placeholder without issuing a component query.
    let place: Place?
    @Binding var tappedPlace: IdentifiablePlace?
    var width: CGFloat = 180

    static let minimumHeight: CGFloat = 220

    var body: some View {
        VStack(spacing: 12) {
            if let place, let placeID = place.placeID {
                PlaceCardMediaView(placeID: placeID, width: width)
                    .id(placeID)
                Button("View map", systemImage: "map") {
                    tappedPlace = IdentifiablePlace(place: place)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .labelStyle(.titleAndIcon)
                .accessibilityLabel("Map and reviews for \(place.displayName ?? "this place")")
                .accessibilityIdentifier("place-card-\(placeID)")
                .padding([.horizontal, .bottom], 12)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.quaternary)
                    .frame(height: Self.minimumHeight)
                    .accessibilityLabel("Loading place")
                    .accessibilityIdentifier("place-card-loading")
            }
        }
        .frame(width: width)
        .frame(minHeight: Self.minimumHeight, alignment: .top)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
