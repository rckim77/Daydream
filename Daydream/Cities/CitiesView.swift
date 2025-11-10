//
//  CitiesView.swift
//  Daydream
//
//  Created by Ray Kim on 10/30/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift
import TipKit

struct CitiesView: View {
    
    @State private var cities: [RandomCity] = []
    @State private var selectedCity: CityRoute?
    @State private var showFeedbackModal = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Namespace private var zoomNS
    
    private let cityCount = 5

    private var scrollViewHorizontalPadding: CGFloat {
        horizontalSizeClass == .compact ? 0 : 96
    }
    
    private var cityCardsVerticalSpacing: CGFloat {
        horizontalSizeClass == .compact ? -38 : -48
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Where do you want to go?")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 32)
                    .padding(.horizontal, 16)
                    .modifier(TopScrollTransition())
                TipView(GettingStartedTip())
                    .modifier(TopScrollTransition())
                VStack(spacing: -60) {
                    ForEach(cities, id: \.city) { city in
                        CityCardView(city: city) { place, image in
                            guard let place, let image else {
                                return
                            }
                            selectedCity = CityRoute(name: city.city, place: place, image: image)
                        }
                        .matchedTransitionSource(id: city.city, in: zoomNS) { source in
                            source
                                .clipShape(RoundedRectangle(cornerRadius: 32))
                        }
                        .modifier(TopScrollTransition())
                    }
                }
            }
            .scrollIndicators(.never)
            .padding(.horizontal, scrollViewHorizontalPadding)
            .safeAreaInset(edge: .bottom, alignment: .center) {
                SearchToolbar { place, image in
                    selectedCity = CityRoute(name: place.description, place: place, image: image)
                } randomCityReceived: { place, image in
                    selectedCity = CityRoute(name: place.description, place: place, image: image)
                } additionalViews: {
                    FeedbackButton {
                        showFeedbackModal = true
                    }
                }
            }
            .fullScreenCover(item: $selectedCity) { item in
                CityDetailView(place: item.place, image: item.image)
                    .navigationTransition(.zoom(sourceID: item.name, in: zoomNS))
            }
        }
        .sheet(isPresented: $showFeedbackModal) {
            FeedbackSheet()
                .presentationDetents([.medium])
        }
        .task {
            var selectedCities = [RandomCity]()
            
            while selectedCities.count < cityCount {
                if let city = getRandomCity(), !selectedCities.contains(where: { $0.city == city.city }) {
                    selectedCities.append(city)
                }
            }

            cities = selectedCities
        }
    }
}

extension CitiesView: RandomCitySelectable {}
