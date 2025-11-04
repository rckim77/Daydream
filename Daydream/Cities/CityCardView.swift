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
    
    private let height: CGFloat = 200

    var body: some View {
        Button {
            onTap(place, image)
        } label: {
            ZStack(alignment: .topLeading) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                    Text(name.0)
                        .font(.largeTitle).bold()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color(.systemBackground).opacity(0.85),
                                                    Color(.systemBackground).opacity(0.55),
                                                    Color.clear],
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                } else {
                    Color(.lightGray)
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .shadow(radius: 3)
                }
            }
        }
        .buttonStyle(CityCardButtonStyle(height: height))
        .task {
            do {
                let result = try await API.PlaceSearch.fetchPlaceAndImageBy(name: "\(name.0), \(name.1)")
                place = result.0
                image = result.1
            } catch {
            }
        }
    }
}
