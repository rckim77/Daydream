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
    let onTap: (Place?, UIImage?) -> Void
    
    @State private var place: Place?
    @State private var image: UIImage?
    @State private var showErrorView = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var height: CGFloat {
        horizontalSizeClass == .compact ? 188 : 280
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
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .contentShape(RoundedRectangle(cornerRadius: 32))
                VStack(spacing: 0) {
                    Text(city.city)
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
        .buttonStyle(CityCardButtonStyle(height: height, horizontalSizeClass: horizontalSizeClass))
        .task {
            await loadResults()
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
