import GooglePlacesSwift
import SwiftUI

struct WishlistCityRow: View {
    let city: RandomCity
    let wishlist: WishlistStore
    let isOpening: Bool
    let onOpenCity: () -> Void
    let onOpenPlace: (Place) -> Void
    let onRemoveCity: () -> Void
    @State private var isExpanded = true

    var body: some View {
        let places = wishlist.places(in: city)
        if places.isEmpty {
            Button(action: onOpenCity) {
                HStack(spacing: 16) {
                    Text(city.city)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer(minLength: 8)
                    if isOpening {
                        ProgressView()
                            .accessibilityLabel("Opening city")
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                            .accessibilityHidden(true)
                    }
                }
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Explore \(city.city), \(city.country)")
            .accessibilityIdentifier("wishlist-city-\(city.city)")
            .swipeActions {
                Button("Remove", systemImage: "heart.slash", role: .destructive, action: onRemoveCity)
            }
        } else {
            DisclosureGroup(isExpanded: $isExpanded) {
                Button(action: onOpenCity) {
                    HStack {
                        Label("Explore city", systemImage: "building.2")
                        Spacer()
                        if isOpening { ProgressView() }
                    }
                    .frame(minHeight: 44)
                }
                .accessibilityIdentifier("wishlist-explore-\(city.city)")
                ForEach(WishlistPlace.Kind.allCases, id: \.self) { kind in
                    let savedPlaces = places.filter { $0.kind == kind }
                    if !savedPlaces.isEmpty {
                        Text(kind == .sight ? "Sights" : "Eateries")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .accessibilityAddTraits(.isHeader)
                        ForEach(savedPlaces) { savedPlace in
                            WishlistPlaceRow(savedPlace: savedPlace, onOpen: onOpenPlace) {
                                wishlist.removePlace(placeID: savedPlace.placeID, from: city)
                            }
                        }
                    }
                }
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(city.city)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Sights: \(places.filter { $0.kind == .sight }.count) · Eateries: \(places.filter { $0.kind == .eatery }.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("wishlist-city-section-\(city.city)")
            }
            .swipeActions {
                Button("Remove city", systemImage: "heart.slash", role: .destructive, action: onRemoveCity)
            }
        }
    }
}
