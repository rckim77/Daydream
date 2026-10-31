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
    @State private var removingCity: RandomCity?
    @State private var wishlist: WishlistStore

    init() {
        var defaults = UserDefaults.standard
        #if DEBUG
        if let suite = ProcessInfo.processInfo.environment["DAYDREAM_WISHLIST_TEST_SUITE"],
           suite.hasPrefix("Daydream.WishlistUITests."), let isolated = UserDefaults(suiteName: suite) {
            defaults = isolated
        }
        #endif
        _wishlist = State(initialValue: WishlistStore(defaults: defaults))
    }
    
    // MARK: - Current Location
    /// This ensures navigation to current location city is gated behind user interaction.
    @State private var currentLocationButtonTapped = false
    @Environment(CurrentLocationManager.self) private var locationManager
    @State private var prevCurrentLocation: CLLocationCoordinate2D?

    // MARK: - Layout/Animation vars
    @Environment(\.layoutDirection) private var layoutDirection
    @Namespace private var zoomNS
    
    // MARK: - Private constants and computed vars
    private let cityCount = 8
    private let feedbackButtonTransitionID = "feedbackButton"

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let width = min(geometry.size.width, 1100)
                let columns = 2
                let spacing: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 6 : 20
                let cardWidth = max(0, (width - 32 - CGFloat(columns - 1) * spacing) / CGFloat(columns))
                let gridWidth = cardWidth * CGFloat(columns) + CGFloat(columns - 1) * spacing
                let minimumCardHeight = min(260, cardWidth * 2 / 3)
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
                    CityCardsLayout(columns: columns, spacing: spacing, layoutDirection: layoutDirection) {
                        ForEach(cities) { city in
                            CityCardView(city: city, width: cardWidth, minimumHeight: minimumCardHeight,
                                         isSaved: wishlist.contains(city), onWishlistToggle: {
                                if wishlist.contains(city), !wishlist.places(in: city).isEmpty {
                                    removingCity = city
                                } else {
                                    wishlist.toggle(city)
                                }
                            }) { place in
                                selectedCity = CityRoute(name: city.city, place: place, wishlistCity: city)
                            }
                            .matchedTransitionSource(id: city.city, in: zoomNS) { source in
                                source
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .modifier(TopScrollTransition())
                        }
                    }
                    .frame(width: gridWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                }
                .scrollIndicators(.never)
                .frame(width: width)
                .frame(maxWidth: .infinity)
            }
            .toolbar {
                SearchToolbar { place in
                    selectedCity = CityRoute(name: place.description, place: place)
                } randomCityReceived: { place in
                    selectedCity = CityRoute(name: place.description, place: place)
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
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            WishlistView(wishlist: wishlist)
                        } label: {
                            Label("Wishlist", systemImage: "heart")
                                .labelStyle(.iconOnly)
                        }
                        .accessibilityIdentifier("wishlist-button")
                    }
                    .adaptsToVerticalToolbar()
                    ToolbarItem(placement: .bottomBar) {
                        FeedbackButton {
                            showFeedbackModal = true
                        }
                    }
                    .matchedTransitionSource(id: feedbackButtonTransitionID, in: zoomNS)
                }
            }
            .fullScreenCover(item: $selectedCity) { item in
                CityDetailView(place: item.place, wishlist: wishlist, sourceCity: item.wishlistCity)
                    .navigationTransition(.zoom(sourceID: item.name, in: zoomNS))
            }
        }
        .modifier(WishlistCityRemovalConfirmation(city: $removingCity, wishlist: wishlist))
        .sheet(isPresented: $showFeedbackModal) {
            FeedbackSheet()
                .presentationDetents([.medium])
                .navigationTransition(.zoom(sourceID: feedbackButtonTransitionID, in: zoomNS))
        }
        .errorAlert(isPresented: $showErrorAlert)
        .task {
            guard cities.isEmpty else { return }
            var preferredNames: [String] = []
            #if DEBUG
            preferredNames = ProcessInfo.processInfo.environment["DAYDREAM_UI_CAPTURE_CITIES"]?
                .components(separatedBy: "|") ?? []
            #endif
            do {
                cities = try RandomCityCatalog.load().discoveryCities(count: cityCount, preferredNames: preferredNames)
            } catch {
                showErrorAlert = true
            }
            
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
        let place = try await API.PlaceSearch.fetchCurrentCityBy(location)
        return CityRoute(name: place.description, place: place)
    }
}
