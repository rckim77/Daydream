import SwiftUI

struct WishlistCityRow: View {
    let city: RandomCity
    let wishlist: WishlistStore
    let isOpening: Bool
    let onOpenCity: () -> Void
    let onOpenPlace: (MapPlace) -> Void
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
                Button("Remove", systemImage: "heart.slash", action: onRemoveCity)
                    .tint(.red)
            }
        } else {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(WishlistPlace.Kind.allCases, id: \.self) { kind in
                    let savedPlaces = places.filter { $0.kind == kind }
                    if !savedPlaces.isEmpty {
                        Text(kind == .sight ? "Sights" : "Eateries")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .accessibilityAddTraits(.isHeader)
                            .listRowInsets(EdgeInsets(top: 6, leading: 32, bottom: 2, trailing: 16))
                        ForEach(savedPlaces) { savedPlace in
                            WishlistPlaceRow(savedPlace: savedPlace, onOpen: onOpenPlace) {
                                wishlist.removePlace(placeID: savedPlace.placeID, from: city)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(city.city)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Sights: \(places.filter { $0.kind == .sight }.count) · Eateries: \(places.filter { $0.kind == .eatery }.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("wishlist-city-section-\(city.city)")
                    Button(action: onOpenCity) {
                        Group {
                            if isOpening {
                                ProgressView()
                            } else {
                                Image(systemName: "building.2")
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
            }
            .swipeActions {
                // A destructive swipe optimistically deletes one row before confirmation,
                // which conflicts with this disclosure group's dynamically expanded children.
                Button("Remove city", systemImage: "heart.slash", action: onRemoveCity)
                    .tint(.red)
            }
        }
    }
}
