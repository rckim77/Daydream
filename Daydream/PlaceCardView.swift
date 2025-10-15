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
    let place: GooglePlacesSwift.Place?
    @Binding var showMapVC: Bool
    
    @State private var image: UIImage?
    
    private let width: CGFloat = 130
    private let height: CGFloat = 220

    var body: some View {
        ZStack(alignment: .bottom) {
            if let place = place, let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height) // this prevents weird UI layout issues
                Text(place.displayName ?? "?")
                    .frame(maxWidth: .infinity)
                    .font(.subheadline).bold()
                    .lineLimit(3)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(colors: [Color.clear, Color(.systemBackground).opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    )
            }
        }
        .frame(width: width, height: height)
        .background(Color(.systemGray))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            showMapVC = true
        }
        .task {
            guard let photo = place?.photos?.first else {
                return
            }
            let fetchedImage = await API.PlaceSearch.fetchImageBy(photo: photo)
            image = fetchedImage
        }
    }
}
