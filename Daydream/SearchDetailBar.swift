//
//  SearchDetailBar.swift
//  Daydream
//
//  Created by Ray Kim on 10/13/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift

struct SearchDetailBar: View {
    
    @State private var showAutocompleteWidget = false
    var autocompleteTapped: (GooglePlacesSwift.Place, UIImage?) -> Void
    
    var body: some View {
        Button {
            showAutocompleteWidget.toggle()
        } label: {
            Label("Search", systemImage: "magnifyingglass")
        }
        .buttonStyle(.bordered)
        .tint(.white)
        .buttonBorderShape(.capsule)
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
    }
}
