import SwiftUI

struct WishlistCityRow: View {
    let city: RandomCity
    let wishlist: WishlistStore
    let isOpening: Bool
    let onOpenCity: () -> Void
    let onOpenPlace: (MapPlace) -> Void
    let onRemoveCity: () -> Void

    var body: some View {
        let places = wishlist.places(in: city)
        HStack(spacing: 12) {
            Button(action: onOpenCity) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(city.city)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if !places.isEmpty {
                        Text("Sights: \(places.filter { $0.kind == .sight }.count) · Eateries: \(places.filter { $0.kind == .eatery }.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Explore \(city.city)")
            .accessibilityIdentifier("wishlist-city-section-\(city.city)")
            Button(action: onOpenCity) {
                Group {
                    if isOpening {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }
                .frame(width: 44, height: 44)
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .circle)
            .fixedSize()
            .accessibilityLabel("Explore \(city.city)")
            .accessibilityIdentifier("wishlist-explore-\(city.city)")
        }
        .padding(.vertical, 4)
        .swipeActions {
            // Let the confirmation and data update drive deletion of the city and its places.
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
