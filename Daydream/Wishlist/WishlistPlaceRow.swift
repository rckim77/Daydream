import SwiftUI

struct WishlistPlaceRow: View {
    let savedPlace: WishlistPlace
    let onOpen: (MapPlace) -> Void
    let onRemove: () -> Void
    @State private var place: MapPlace?
    @State private var isLoading = true
    @State private var retryID = 0

    var body: some View {
        HStack(spacing: 12) {
            Button(action: openPlace) {
                HStack(spacing: 12) {
                    Image(systemName: savedPlace.kind == .sight ? "binoculars" : "fork.knife")
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        if let name = place?.displayName {
                            Text(name)
                                .foregroundStyle(.primary)
                            Text("Google Maps")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(savedPlace.kind == .sight ? "Saved sight" : "Saved eatery")
                                .foregroundStyle(.primary)
                            Text(isLoading ? "Loading details…" : "Details unavailable. Tap to retry.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer(minLength: 4)
                }
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .accessibilityIdentifier("wishlist-place-\(savedPlace.placeID)")
            .accessibilityHint(place == nil ? "Retry loading place details" : "Open map and reviews")
            if isLoading {
                ProgressView()
                    .frame(width: 44, height: 44)
            } else {
                Button(action: openPlace) {
                    Image(systemName: place == nil ? "arrow.clockwise" : "map")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
                .accessibilityLabel(place == nil ? "Retry saved place details" : "Map and reviews for \(place?.displayName ?? "saved place")")
                .accessibilityIdentifier("wishlist-place-map-\(savedPlace.placeID)")
            }
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 32, bottom: 4, trailing: 16))
        .swipeActions {
            Button("Remove", systemImage: "heart.slash", action: onRemove)
                .tint(.red)
        }
        .task(id: retryID) {
            isLoading = true
            let result = try? await API.PlaceSearch.fetchWishlistPlaceBy(placeID: savedPlace.placeID)
            guard !Task.isCancelled else { return }
            place = result
            isLoading = false
        }
    }

    private func openPlace() {
        if let place {
            onOpen(place)
        } else {
            retryID += 1
        }
    }
}
