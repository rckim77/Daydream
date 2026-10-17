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

    let city: RandomCity
    var height: CGFloat = 220
    let onTap: (Place?, UIImage?) -> Void
    
    @State private var place: Place?
    @State private var image: UIImage?
    @State private var showErrorView = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        Button {
            onTap(place, image)
        } label: {
            ZStack(alignment: .topLeading) {
                CityCardBackground(image: image, height: height)
                VStack(spacing: 0) {
                    Text(city.city)
                        .font(.largeTitle).bold()
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(colors: [Color(.systemBackground).opacity(0.85),
                                                    Color(.systemBackground).opacity(0.55),
                                                    Color.clear],
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                    if showErrorView {
                        Button {
                            Task {
                                await loadResults()
                            }
                        } label: {
                            Label("Failed to load.", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .accessibilityIdentifier("city-\(image == nil ? "loading" : "loaded")-\(city.city)")
        .buttonStyle(CityCardButtonStyle(height: height, horizontalSizeClass: horizontalSizeClass))
        .task {
            await loadResults()
        }
    }

    private func loadResults() async -> Void {
        do {
            showErrorView = false
            let result = try await API.PlaceSearch.fetchPlaceAndImageBy(city, horizontalSizeClass: horizontalSizeClass)
            place = result.0
            image = result.1
        } catch {
            showErrorView = true
        }
    }
}
