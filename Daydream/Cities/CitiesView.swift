//
//  CitiesView.swift
//  Daydream
//
//  Created by Ray Kim on 10/30/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import CoreLocation
import SwiftUI
import GooglePlacesSwift
import TipKit

struct CitiesView: View {
    
    // MARK: - State vars
    @State private var cities: [RandomCity] = []
    @State private var selectedCity: CityRoute?
    @State private var showFeedbackModal = false
    @State private var showErrorAlert = false
    
    // MARK: - Current Location
    /// This ensures navigation to current location city is gated behind user interaction.
    @State private var currentLocationButtonTapped = false
    @Environment(CurrentLocationManager.self) private var locationManager
    @State private var prevCurrentLocation: CLLocationCoordinate2D?

    // MARK: - Layout/Animation vars
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Namespace private var zoomNS
    
    // MARK: - Private constants and computed vars
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
                } currentLocationTapped: {
                    currentLocationButtonTapped = true
                    guard let prevCurrentLocation = prevCurrentLocation,
                          locationManager.location == prevCurrentLocation else {
                        // the .onChange(of:) will be triggered and programmatically navigate
                        return
                    }
                    Task {
                        do {
                            selectedCity = try await fetchCityRoute(prevCurrentLocation)
                        } catch {
                            showErrorAlert = true
                        }
                    }
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
        .errorAlert(isPresented: $showErrorAlert)
        .task {
            var selectedCities = [RandomCity]()
            
            while selectedCities.count < cityCount {
                if let city = getRandomCity(), !selectedCities.contains(where: { $0.city == city.city }) {
                    selectedCities.append(city)
                }
            }

            cities = selectedCities
            
            // seed prevCurrentLocation
            prevCurrentLocation = locationManager.location
        }
        .onChange(of: locationManager.location) { _ , currentLocation in
            if let currentLocation = currentLocation, currentLocationButtonTapped {
                prevCurrentLocation = currentLocation
                Task {
                    do {
                        selectedCity = try await fetchCityRoute(currentLocation)
                    } catch {
                        showErrorAlert = true
                    }
                }
            } else {
                print("currentLocation is nil")
            }
        }
    }
    
    private func fetchCityRoute(_ location: CLLocationCoordinate2D) async throws -> CityRoute {
        let (place, image) = try await API.PlaceSearch.fetchCurrentCityBy(location)
        return CityRoute(name: place.description, place: place, image: image)
    }
}

extension CitiesView: RandomCitySelectable {}
