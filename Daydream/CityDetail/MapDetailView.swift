import GooglePlacesSwift
import SwiftUI

struct MapDetailView: View {
    let place: Place
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var mapAppearanceOverride: Bool?

    var body: some View {
        let isViewingDarkMode = mapAppearanceOverride ?? (colorScheme == .dark)

        NavigationStack {
            MapViewControllerRepresentable(place: place, isViewingDarkMode: isViewingDarkMode)
                .ignoresSafeArea(.container, edges: .all)
                .toolbarTitleDisplayMode(.inline)
                .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close", systemImage: "xmark") {
                            dismiss()
                        }
                        .accessibilityIdentifier("map-close-button")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Map Appearance", systemImage: isViewingDarkMode ? "sun.max" : "moon") {
                            mapAppearanceOverride = !isViewingDarkMode
                        }
                        .accessibilityIdentifier("map-appearance-button")
                    }
                }
                .labelStyle(.iconOnly)
                .onChange(of: colorScheme) { _, _ in
                    mapAppearanceOverride = nil
                }
        }
    }
}
