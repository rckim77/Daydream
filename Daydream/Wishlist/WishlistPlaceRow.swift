import GooglePlacesSwift
import SwiftUI

struct WishlistPlaceRow: View {
    let savedPlace: WishlistPlace
    let onOpen: (Place) -> Void
    let onRemove: () -> Void
    @State private var place: Place?
    @State private var isLoading = true
    @State private var retryID = 0

    var body: some View {
        Button {
            if let place {
                onOpen(place)
            } else {
                retryID += 1
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: savedPlace.kind == .sight ? "binoculars" : "fork.knife")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
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
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: place == nil ? "arrow.clockwise" : "map")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .accessibilityIdentifier("wishlist-place-\(savedPlace.placeID)")
        .accessibilityHint(place == nil ? "Retry loading place details" : "Open map and reviews")
        .swipeActions {
            Button("Remove", systemImage: "heart.slash", role: .destructive, action: onRemove)
        }
        .task(id: retryID) {
            isLoading = true
            let result = try? await API.PlaceSearch.fetchPlaceBy(placeId: savedPlace.placeID)
            guard !Task.isCancelled else { return }
            place = result
            isLoading = false
        }
    }
}
