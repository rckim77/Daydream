import GooglePlacesSwift
import SwiftUI

struct PlaceCardView: View {
    /// When this is nil, preserve a placeholder without issuing a component query.
    let place: Place?
    @Binding var tappedPlace: IdentifiablePlace?
    var width: CGFloat = 210

    static let minimumHeight: CGFloat = 220

    var body: some View {
        VStack(spacing: 12) {
            if let place, let placeID = place.placeID {
                PlaceCardMediaView(
                    placeID: placeID,
                    width: width,
                    placeName: place.displayName ?? "this place",
                    onViewMap: { tappedPlace = IdentifiablePlace(place: place) }
                )
                .id(placeID)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.quaternary)
                    .frame(height: Self.minimumHeight)
                    .accessibilityLabel("Loading place")
                    .accessibilityIdentifier("place-card-loading")
            }
        }
        .frame(width: width)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
