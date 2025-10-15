//
//  CityDetailView.swift
//  Daydream
//
//  Created by Ray Kim on 10/14/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift
import MapKit

struct CityDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var showAutocompleteWidget = false
    @State private var sights = [Place]()
    @State private var eateries = [Place]()
    @State private var showLoadingSpinnerForRandomCityButton = false
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var showingMapDetailViewController = false

    @State var place: Place
    @State var image: UIImage
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                Text(place.displayName ?? "")
                    .font(.largeTitle)
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                MapView(mapPosition: $mapPosition, place: place)
                Text("Top Sights")
                    .font(.title)
                    .padding(.horizontal, 24)
                PlacesCarouselView(places: sights, showMapVC: $showingMapDetailViewController)
                Text("Top Eateries")
                    .font(.title)
                    .padding(.horizontal, 24)
                PlacesCarouselView(places: eateries, showMapVC: $showingMapDetailViewController)
            }
            .frame(maxWidth: .infinity)
        }
        .background(content: {
            Image(uiImage: image)
                .aspectRatio(contentMode: .fill)
                .blur(radius: 36)
        })
        .safeAreaInset(edge: .bottom, alignment: .center) {
            HStack {
                Button {
                    showAutocompleteWidget.toggle()
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .modifier(SearchActionStyle(shape: .capsule))
                .placeAutocomplete(filter: AutocompleteFilter(types: [.cities]), show: $showAutocompleteWidget) { suggestion, _ in
                    print("\(suggestion)")
                } onError: { error in
                    print(error.localizedDescription)
                }
                Button {
                    showLoadingSpinnerForRandomCityButton = true
                    Task {
                        do {
                            let result = try await API.PlaceSearch.fetchRandomCity()
                            // now update all observed data (which will update UI automatically)
                            showLoadingSpinnerForRandomCityButton = false
                            place = result.0
                            if let resultImage = result.1 {
                                image = resultImage
                            }
                            mapPosition = createMapPosition(place.location)
                            await fetchSightsAndEateries(place)
                        } catch {
                            showLoadingSpinnerForRandomCityButton = false
                        }
                    }
                } label: {
                    if showLoadingSpinnerForRandomCityButton {
                        ProgressView()
                            .padding(12)
                    } else {
                        Image(systemName: "shuffle")
                            .padding(12)
                    }
                }
                .modifier(SearchActionStyle(shape: .capsule))
                Spacer()
                    .frame(width: 2) // this helps the button spacing match SearchActionsView
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "house.fill")
                        .padding(12)
                }
                .modifier(SearchActionStyle(shape: .circle))
            }
            .frame(maxWidth: .infinity)
        }
        .task {
            mapPosition = createMapPosition(place.location)
            await fetchSightsAndEateries(place)
        }
        .sheet(isPresented: $showingMapDetailViewController) {
            MapViewControllerRepresentable(place: place)
        }
    }
    
    private func fetchSightsAndEateries(_ city: Place) async -> Void {
        guard let city = place.displayName else { return }
        do {
            async let fetchSights = API.PlaceSearch.fetchPlacesFor(city: city)
            async let fetchEateries = API.PlaceSearch.fetchEateriesFor(city: city)
            
            sights = try await fetchSights
            eateries = try await fetchEateries
        } catch {
            return
        }
    }
    
    private func createMapPosition(_ location: CLLocationCoordinate2D) -> MapCameraPosition {
        .region(MKCoordinateRegion(center: place.location, span: .init(latitudeDelta: 0.4, longitudeDelta: 0.4)))
    }
}
