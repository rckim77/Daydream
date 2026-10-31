import SwiftUI

struct WishlistCityRow: View {
    let city: RandomCity
    let wishlist: WishlistStore
    let zoomNamespace: Namespace.ID
    let isOpening: Bool
    let onOpenCity: () -> Void
    let onOpenPlace: (MapPlace) -> Void
    let onRemoveCity: () -> Void

    var body: some View {
        let places = wishlist.places(in: city)
        Button(action: onOpenCity) {
            HStack(spacing: 12) {
                Text(city.city)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer(minLength: 4)
                Group {
                    if isOpening {
                        ProgressView()
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Explore \(city.city)")
        .accessibilityIdentifier("wishlist-city-section-\(city.city)")
        .matchedTransitionSource(id: city.id, in: zoomNamespace) { source in
            source.clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .listRowInsets(EdgeInsets())
        .swipeActions {
            // Avoid destructive swipe actions deleting rows before confirmation.
            Button("Remove city", systemImage: "heart.slash", action: onRemoveCity)
                .tint(.red)
        }
        ForEach(places) { savedPlace in
            WishlistPlaceRow(savedPlace: savedPlace, onOpen: onOpenPlace) {
                wishlist.removePlace(placeID: savedPlace.placeID, from: city)
            }
        }
    }
}
