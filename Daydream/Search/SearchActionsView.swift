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

    var randomCityButtonTapped: () -> Void
    var feedbackButtonTapped: () -> Void
    var autocompleteTapped: (GooglePlacesSwift.Place, UIImage?) -> Void
    
    var body: some View {
        HStack {
            Button {
                showAutocompleteWidget.toggle()
            } label: {
                Label("Search", systemImage: "magnifyingglass")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
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
            
            Button {
                randomCityButtonTapped()
            } label: {
                Image(systemName: "shuffle")
                    .padding(12)
            }
            .modifier(SearchActionStyle(shape: .capsule))

            Button {
                feedbackButtonTapped()
            } label: {
                Image(systemName: "questionmark")
                    .padding(12)
            }
            .modifier(SearchActionStyle(shape: .circle))
        }
    }
}

private struct SearchActionStyle: ViewModifier {
    
    let shape: ButtonBorderShape
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            if shape == .circle {
                content
                    .buttonStyle(.glass)
                    .clipShape(Circle())
            } else {
                content
                    .buttonStyle(.glass)
            }
        } else {
            content
                .buttonStyle(.bordered)
                .tint(.white)
                .buttonBorderShape(shape)
        }
    }
}
