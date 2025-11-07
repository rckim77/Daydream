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
    
    @State private var cityNames: [(String, String)] = []
    @State private var selectedCity: CityRoute?
    @State private var showFeedbackAlert = false

    @Environment(\.openURL) private var openURL
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Namespace private var zoomNS
    
    private var cityCount: Int {
        horizontalSizeClass == .compact  ? 4 : 5
    }
    
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
                        showFeedbackAlert = true
                    }
                }
            }
            .fullScreenCover(item: $selectedCity) { item in
                CityDetailView(place: item.place, image: item.image)
                    .navigationTransition(.zoom(sourceID: item.name, in: zoomNS))
            }
        }
        .feedbackAlert(showAlert: $showFeedbackAlert, onEmailButtonPress: { url in
            openURL(url)
        })
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
