//
//  SearchToolbar.swift
//  Daydream
//
//  Created by Ray Kim on 10/13/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift

struct SearchToolbar<Content: ToolbarContent>: ToolbarContent {
    
    var autocompleteTapped: (Place, UIImage?) -> Void
    var randomCityReceived: (Place, UIImage) -> Void
    var currentLocationTapped: () -> Void

    @ToolbarContentBuilder let additionalViews: Content
    @State private var showAutocompleteWidget = false
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button("Search", systemImage: "magnifyingglass") {
                showAutocompleteWidget = true
            }
            .labelStyle(.iconOnly)
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
        ToolbarSpacer(.fixed, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            RandomCityButton { place, image in
                randomCityReceived(place, image)
            }
        }
        .adaptsToVerticalToolbar()
        ToolbarItem(placement: .bottomBar) {
            CurrentCityButton(currentLocationTapped: currentLocationTapped)
        }
        additionalViews
    }
}

extension ToolbarContent {
    @ToolbarContentBuilder
    func adaptsToVerticalToolbar() -> some ToolbarContent {
        // Allow the custom loading button to join the Duo's vertical toolbar.
        if #available(iOS 27.1, *) {
            self.axisBehavior(.verticalPreferred)
        } else {
            self
        }
    }
}
