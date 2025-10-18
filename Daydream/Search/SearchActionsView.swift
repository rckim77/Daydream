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

    var randomCityReceived: (Place, UIImage?) -> Void
    var feedbackButtonTapped: () -> Void
    var autocompleteTapped: (Place, UIImage?) -> Void
    
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
                    let fetchPlaceRequest = FetchPlaceRequest(
                        placeID: suggestion.placeID,
                        placeProperties: [.displayName, .formattedAddress, .photos, .coordinate]
                    )
                    
                    switch await PlacesClient.shared.fetchPlace(with: fetchPlaceRequest) {
                    case .success(let place):
                        if let photo = place.photos?.first {
                            let fetchPhotoRequest = FetchPhotoRequest(photo: photo, maxSize: photo.maxSize)
                            switch await PlacesClient.shared.fetchPhoto(with: fetchPhotoRequest) {
                            case .success(let image):
                                autocompleteTapped(place, image)
                            case .failure(_):
                                autocompleteTapped(place, nil)
                            }
                        } else {
                            autocompleteTapped(place, nil)
                        }
                    case .failure(_):
                        print("error")
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
    }
}

extension SearchActionsView: RandomCitySelectable {}


