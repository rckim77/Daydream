//
//  SearchActionsView.swift
//  Daydream
//
//  Created by Ray Kim on 10/13/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift

struct SearchActionsView: View {

    @State private var showAutocompleteWidget = false
    @State private var showLoadingSpinnerForRandomCityButton = false

    var autocompleteTapped: (Place, UIImage?) -> Void
    var randomCityReceived: (Place, UIImage) -> Void
    var feedbackButtonTapped: () -> Void
    
    var body: some View {
        HStack {
            Button {
                showAutocompleteWidget.toggle()
            } label: {
                Label("Search", systemImage: "magnifyingglass")
                    .foregroundStyle(.primary)
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
            FeedbackButton {
                feedbackButtonTapped()
            }
        }
        .padding(.bottom, 8)
    }
}

extension SearchActionsView: RandomCitySelectable {}


