import GooglePlacesSwift
import SwiftUI

struct MapDetailView: View {
    let place: MapPlace
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var mapAppearanceOverride: Bool?
    @State private var isViewing3D = true

    init(place: Place) {
        self.place = MapPlace(place: place)
    }

    init(mapPlace: MapPlace) {
        place = mapPlace
    }

    var body: some View {
        let isViewingDarkMode = mapAppearanceOverride ?? (colorScheme == .dark)

        NavigationStack {
            MapViewControllerRepresentable(
                place: place,
                isViewingDarkMode: isViewingDarkMode,
                isViewing3D: isViewing3D
            )
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
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Map Appearance", systemImage: isViewingDarkMode ? "sun.max" : "moon") {
                            mapAppearanceOverride = !isViewingDarkMode
                        }
                        .accessibilityIdentifier("map-appearance-button")

                        Button(isViewing3D ? "Show 2D map" : "Show 3D map",
                               systemImage: isViewing3D ? "view.2d" : "view.3d") {
                            isViewing3D.toggle()
                        }
                        .accessibilityIdentifier("map-dimension-button")
                    }
                }
                .labelStyle(.iconOnly)
                .onChange(of: colorScheme) { _, _ in
                    mapAppearanceOverride = nil
                }
        }
    }
}
