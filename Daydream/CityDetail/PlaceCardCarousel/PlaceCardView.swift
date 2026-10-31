import GooglePlacesSwift
import SwiftUI

struct PlaceCardView: View {
    /// When this is nil, preserve a placeholder without issuing a component query.
    let place: Place?
    let wishlistCity: RandomCity?
    let wishlist: WishlistStore
    let kind: WishlistPlace.Kind
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
                .overlay(alignment: .topLeading) {
                    if let city = wishlistCity {
                        let isSaved = wishlist.contains(placeID: placeID, in: city)
                        Button {
                            wishlist.togglePlace(placeID: placeID, kind: kind, in: city)
                        } label: {
                            Image(systemName: isSaved ? "heart.fill" : "heart")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(isSaved ? Color.pink : Color.primary)
                                .frame(width: 44, height: 44)
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.regular.interactive(), in: .circle)
                        .accessibilityLabel(isSaved ? "Remove \(place.displayName ?? "place") from wishlist" : "Save \(place.displayName ?? "place") to wishlist")
                        .accessibilityValue(isSaved ? "Saved" : "Not saved")
                        .accessibilityIdentifier("place-wishlist-\(kind.rawValue)-\(placeID)")
                        .sensoryFeedback(.selection, trigger: isSaved)
                        .padding(12)
                    }
                }
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
