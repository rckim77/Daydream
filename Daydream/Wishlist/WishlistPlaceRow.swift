import SwiftUI

struct WishlistPlaceRow: View {
    let savedPlace: WishlistPlace
    let onOpen: (MapPlace) -> Void
    let onRemove: () -> Void
    @State private var place: MapPlace?
    @State private var isLoading = true
    @State private var retryID = 0

    var body: some View {
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
                    } else {
                        Text(savedPlace.kind == .sight ? "Saved sight" : "Saved eatery")
                            .foregroundStyle(.primary)
                        Text(isLoading ? "Loading details…" : "Details unavailable. Tap to retry.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 4)
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: place == nil ? "arrow.clockwise" : "map")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 44, height: 44)
                .glassEffect(.regular.interactive(), in: .circle)
                .accessibilityHidden(true)
            }
            .padding(EdgeInsets(top: 4, leading: 32, bottom: 4, trailing: 16))
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .accessibilityIdentifier("wishlist-place-\(savedPlace.placeID)")
        .accessibilityHint(place == nil ? "Retry loading place details" : "Open map and reviews")
        .listRowInsets(EdgeInsets())
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
