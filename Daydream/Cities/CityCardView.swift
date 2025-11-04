//
//  CityCardView.swift
//  Daydream
//
//  Created by Ray Kim on 10/30/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift

struct CityCardView: View {

    let name: (String, String)
    let onTap: (Place?, UIImage?) -> Void
    
    @State private var place: Place?
    @State private var image: UIImage?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var height: CGFloat {
        horizontalSizeClass == .compact ? 200 : 320
    }
    
    private var cityTextVerticalPadding: CGFloat {
        horizontalSizeClass == .compact ? 16 : 36
    }

    var body: some View {
        Button {
            onTap(place, image)
        } label: {
            ZStack(alignment: .topLeading) {
                backgroundView
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .contentShape(RoundedRectangle(cornerRadius: 24))
                Text(name.0)
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, cityTextVerticalPadding)
                    .background(
                        LinearGradient(colors: [Color(.systemBackground).opacity(0.85),
                                                Color(.systemBackground).opacity(0.55),
                                                Color.clear],
                                       startPoint: .top,
                                       endPoint: .bottom)
                    )
            }
        }
        .buttonStyle(CityCardButtonStyle(height: height, horizontalSizeClass: horizontalSizeClass))
        .task {
            do {
                let result = try await API.PlaceSearch.fetchPlaceAndImageBy(name: "\(name.0), \(name.1)",
                                                                            horizontalSizeClass: horizontalSizeClass)
                place = result.0
                image = result.1
            } catch {
            }
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Color(.lightGray)
        }
    }
}
