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
    var expandsToFillHeight = false
    
    @State private var image: UIImage?
    
    private var shouldShowPriceLevel: Bool {
        guard let place = place else { return false }
        return place.priceLevel != .free && place.priceLevel != .unspecified
    }

    private let width: CGFloat = 130
    static let minimumHeight: CGFloat = 220

    var body: some View {
        Button {
            if let place = place {
                let identifiablePlace = IdentifiablePlace(place: place)
                tappedPlace = identifiablePlace
            }
        } label: {
            Color(.lightGray)
                .aspectRatio(width / Self.minimumHeight, contentMode: .fit)
                .overlay {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .overlay(alignment: .bottom) {
                    if let place, image != nil {
                        VStack(alignment: .leading) {
                            if shouldShowPriceLevel {
                                PriceLevelView(priceLevel: place.priceLevel)
                                    .padding(6)
                                Spacer()
                            }
                            Text(place.displayName ?? "?")
                                .font(.subheadline).bold()
                                .lineLimit(3)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
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
            .frame(width: expandsToFillHeight ? nil : width, height: expandsToFillHeight ? nil : Self.minimumHeight)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .task {
            guard let photo = place?.photos?.first else {
                return
            }

            if let fetchedImage = try? await API.PlaceSearch.fetchImageBy(photo: photo) {
                image = fetchedImage
            }
        }
    }
}
