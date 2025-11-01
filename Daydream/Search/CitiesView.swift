//
//  CitiesView.swift
//  Daydream
//
//  Created by Ray Kim on 10/30/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift

struct CitiesView: View {
    
    private let cityCount = 6
    
    @State private var cityNames: [(String, String)] = []
    
    var body: some View {
        ScrollView {
            Text("Where do you want to go?")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase == .identity || phase == .bottomTrailing ? 1 : 0)
                        .scaleEffect(phase == .identity || phase == .bottomTrailing ? 1 : 0.75)
                }
            VStack(spacing: -38) {
                ForEach(cityNames, id: \.0) { name in
                    CityCardView(name: name)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase == .identity || phase == .bottomTrailing ? 1 : 0)
                                .scaleEffect(phase == .identity || phase == .bottomTrailing ? 1 : 0.75)
                        }
                }
            }
        }
        .scrollIndicators(.never)
        .safeAreaInset(edge: .bottom, alignment: .center) {
            SearchActionsView(randomCityReceived: { _, _ in },
                              feedbackButtonTapped: {},
                              autocompleteTapped: { _, _ in })
        }
        .task {
            var cities = [(String, String)]()
            
            while cities.count < 7 {
                if let city = getRandomCity(), !cities.contains(where: { $0.0 == city.0 }) {
                    cities.append(city)
                }
            }

            cityNames = cities
        }
    }
}

extension CitiesView: RandomCitySelectable {}
