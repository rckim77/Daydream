//
//  SearchToolbar.swift
//  Daydream
//
//  Created by Ray Kim on 10/13/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift

struct SearchToolbar<Content: View>: View {
    
    var autocompleteTapped: (Place, UIImage?) -> Void
    var randomCityReceived: (Place, UIImage) -> Void
    var currentLocationTapped: () -> Void

    @ViewBuilder let additionalViews: Content

    @State private var showAutocompleteWidget = false
    @State private var showLoadingSpinnerForRandomCityButton = false
    
    var body: some View {
        HStack {
            Button {
                showAutocompleteWidget.toggle()
            } label: {
                Label("Search", systemImage: "magnifyingglass")
            }
            .modifier(SearchActionStyle(shape: .capsule))
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
            RandomCityButton { place, image in
                randomCityReceived(place, image)
            }
            Button {
                currentLocationTapped()
            } label: {
                Image(systemName: "location.fill")
            }
            .modifier(SearchActionStyle(shape: .circle))
            additionalViews
        }
        .padding(.bottom, 8)
    }
}
