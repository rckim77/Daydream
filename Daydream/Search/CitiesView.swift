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
    @State private var selectedCity: CityRoute?
    @Namespace private var zoomNS
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Where do you want to go?")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 32)
                    .padding(.horizontal, 16)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase == .identity || phase == .bottomTrailing ? 1 : 0)
                            .scaleEffect(phase == .identity || phase == .bottomTrailing ? 1 : 0.75)
                    }
                VStack(spacing: -38) {
                    ForEach(cityNames, id: \.0) { name in
                        CityCardView(name: name) { place, image in
                            guard let place, let image else {
                                return
                            }
                            selectedCity = CityRoute(name: name.0, place: place, image: image)
                        }
                        .matchedTransitionSource(id: name.0, in: zoomNS) { source in
                            source
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
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
                SearchActionsView(randomCityReceived: { place, image in
                    selectedCity = CityRoute(name: place.description, place: place, image: image)
                },
                                  feedbackButtonTapped: {},
                                  autocompleteTapped: { _, _ in })
            }
            .fullScreenCover(item: $selectedCity) { item in
                CityDetailView(place: item.place, image: item.image)
                    .navigationTransition(.zoom(sourceID: item.name, in: zoomNS))
            }
        }
        .task {
            var cities = [(String, String)]()
            
            while cities.count < cityCount {
                if let city = getRandomCity(), !cities.contains(where: { $0.0 == city.0 }) {
                    cities.append(city)
                }
            }

            cityNames = cities
        }
    }
}

extension CitiesView: RandomCitySelectable {}
