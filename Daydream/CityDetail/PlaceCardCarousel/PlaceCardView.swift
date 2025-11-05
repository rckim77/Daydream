//
//  PlaceCardView.swift
//  Daydream
//
//  Created by Ray Kim on 10/14/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift

struct PlaceCardView: View {
    
    /// When this is `nil`, a placeholder view will render
    let place: Place?
    @Binding var tappedPlace: IdentifiablePlace?
    
    @State private var image: UIImage?
    
    private var shouldShowPriceLevel: Bool {
        guard let place = place else { return false }
        return place.priceLevel != .free && place.priceLevel != .unspecified
    }

    private let width: CGFloat = 130
    private let height: CGFloat = 220

    var body: some View {
        Button {
            if let place = place {
                let identifiablePlace = IdentifiablePlace(place: place)
                tappedPlace = identifiablePlace
            }
        } label: {
            ZStack(alignment: .bottom) {
                if let place = place, let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height) // this prevents weird UI layout issues
                    VStack(alignment: .leading) {
                        if shouldShowPriceLevel {
                            PriceLevelView(priceLevel: place.priceLevel)
                                .padding(6)
                            Spacer()
                        }
                        Text(place.displayName ?? "?")
                            .frame(maxWidth: .infinity)
                            .font(.subheadline).bold()
                            .lineLimit(3)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(colors: [Color.clear,
                                                        Color(.systemBackground).opacity(0.5),
                                                        Color(.systemBackground).opacity(0.7)],
                                               startPoint: .top,
                                               endPoint: .bottom)
                            )
                    }
                }
            }
            .tint(.primary)
            .frame(width: width, height: height)
            .background(Color(.lightGray))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .task {
            guard let photo = place?.photos?.first else {
                return
            }

            let hashKey = String(photo.hashValue)
            
            guard ImageCache.shared.get(forKey: hashKey) == nil else {
                return
            }

            if let fetchedImage = try? await API.PlaceSearch.fetchImageBy(photo: photo) {
                ImageCache.shared.set(fetchedImage, forKey: hashKey)
                image = fetchedImage
            }
        }
    }
}
