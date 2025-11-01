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
    
    @State private var place: Place?
    @State private var image: UIImage?
    
    private let height: CGFloat = 140

    var body: some View {
        Button {
            // use place
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
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [Color(.systemBackground).opacity(0.79),
                                                    Color(.systemBackground).opacity(0.55),
                                                    Color.clear],
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
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
