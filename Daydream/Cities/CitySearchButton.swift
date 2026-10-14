import GooglePlacesSwift
import SwiftUI

struct CitySearchButton: View {
    let autocompleteTapped: (Place, UIImage?) -> Void
    @State private var showAutocompleteWidget = false

    var body: some View {
        Button {
            showAutocompleteWidget = true
        } label: {
            if #available(iOS 27.1, *) {
                ToolbarSearchLabel()
            } else {
                Label("Search", systemImage: "magnifyingglass")
                    .labelStyle(.titleAndIcon)
            }
        }
        .accessibilityLabel("Search")
        .accessibilityIdentifier("city-search-button")
        .placeAutocomplete(filter: AutocompleteFilter(types: [.cities]), show: $showAutocompleteWidget) { suggestion, _ in
            Task {
                do {
                    let result = try await API.PlaceSearch.fetchPlaceAndImageBy(placeId: suggestion.placeID)
                    autocompleteTapped(result.0, result.1)
                } catch {
                    print(error.localizedDescription)
                }
            }
        } onError: { error in
            print(error.localizedDescription)
        }
    }
}
