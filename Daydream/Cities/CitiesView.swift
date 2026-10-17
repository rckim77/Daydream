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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutDirection) private var layoutDirection
    @Namespace private var zoomNS
    
    // MARK: - Private constants and computed vars
    private let cityCount = 6
    private let feedbackButtonTransitionID = "feedbackButton"

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let width = min(geometry.size.width, 1100)
                let columns = width >= 640 && !dynamicTypeSize.isAccessibilitySize ? 2 : 1
                ScrollView {
                    Text("Where do you want to go?")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 32)
                        .padding(.horizontal, 16)
                        .modifier(TopScrollTransition())
                    TipView(GettingStartedTip())
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)
                        .modifier(TopScrollTransition())
                    CityCardsLayout(columns: columns, spacing: columns == 1 && !dynamicTypeSize.isAccessibilitySize ? -60 : 20, layoutDirection: layoutDirection) {
                        ForEach(cities, id: \.city) { city in
                            CityCardView(city: city, height: columns == 1 ? 220 : 260) { place, image in
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
                    .padding(.horizontal, 16)
                }
                .scrollIndicators(.never)
                .frame(width: width)
                .frame(maxWidth: .infinity)
            }
            .toolbar {
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
                    ToolbarItem(placement: .bottomBar) {
                        FeedbackButton {
                            showFeedbackModal = true
                        }
                    }
                    .matchedTransitionSource(id: feedbackButtonTransitionID, in: zoomNS)
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
                .navigationTransition(.zoom(sourceID: feedbackButtonTransitionID, in: zoomNS))
        }
        .errorAlert(isPresented: $showErrorAlert)
        .task {
            guard cities.isEmpty else { return }
            var selectedCities = [RandomCity]()
            #if DEBUG
            if let names = ProcessInfo.processInfo.environment["DAYDREAM_UI_CAPTURE_CITIES"]?.components(separatedBy: "|"),
               let url = Bundle.main.url(forResource: "randomCitiesJSON", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let available = try? JSONDecoder().decode([RandomCity].self, from: data) {
                selectedCities = names.prefix(cityCount).compactMap { name in available.first { $0.city == name } }
            }
            #endif

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
