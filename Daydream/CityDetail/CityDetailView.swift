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

    // MARK: - State vars
    @State var place: Place
    @State var image: UIImage?

    @State private var showAutocompleteWidget = false
    @State private var sights = [Place]()
    @State private var eateries = [Place]()
    @State private var showLoadingSpinnerForRandomCityButton = false
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var showingMapDetailViewController = false
    @State private var tappedCardPlace: IdentifiablePlace?
    /// This ensures navigation to current location city is gated behind user interaction.
    @State private var currentLocationButtonTapped = false
    @State private var prevCurrentLocation: CLLocationCoordinate2D?
    
    // MARK: - Environment vars
    @Environment(\.dismiss) var dismiss
    @Environment(CurrentLocationManager.self) private var locationManager
    
    // MARK: - Computed vars
    /// Appends country flag to city name if available
    private var cityText: String {
        var text = place.displayName ?? ""
        if let countryCodeComponent = place.addressComponents?.first(where: { $0.types.contains(.country) }),
           let countryCode = countryCodeComponent.shortName {
            let base = 127397
            var usv = String.UnicodeScalarView()
            for scalar in countryCode.uppercased().unicodeScalars {
                if let offsetScalar = Unicode.Scalar(base + Int(scalar.value)) {
                    usv.append(offsetScalar)
                }
            }
            text += " " + String(usv)
        }
        return text
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 4) {
                Text(cityText)
                    .font(.largeTitle)
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                SummaryView(cityText: cityText)
                MapCardView(mapPosition: $mapPosition, place: place)
                Text("Top Sights")
                    .font(.title)
                    .padding(.horizontal, 24)
                PlacesCarouselView(places: sights, tappedPlace: $tappedCardPlace)
                Text("Top Eateries")
                    .font(.title)
                    .padding(.horizontal, 24)
                PlacesCarouselView(places: eateries, tappedPlace: $tappedCardPlace)
            }
            .frame(maxWidth: .infinity)
        }
        .background(content: {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 36)
            }
        })
        .safeAreaInset(edge: .bottom, alignment: .center) {
            SearchToolbar { autocompletePlace, autocompleteImage in
                place = autocompletePlace
                image = autocompleteImage
                mapPosition = createMapPosition(place.location)
                Task {
                    await fetchSightsAndEateries(place)
                }
            } randomCityReceived: { randomPlace, randomImage in
                place = randomPlace
                image = randomImage
                mapPosition = createMapPosition(place.location)
                Task {
                    await fetchSightsAndEateries(place)
                }
            } currentLocationTapped: {
                currentLocationButtonTapped = true
                guard let prevCurrentLocation = prevCurrentLocation,
                      locationManager.location == prevCurrentLocation else {
                    // the .onChange(of:) will be triggered and programmatically navigate
                    return
                }
                Task {
                    do {
                        try await updateToCurrentCity(prevCurrentLocation)
                    } catch {
                        // handle error
                    }
                }
            } additionalViews: {
                Spacer()
                    .frame(width: 2)
                HomeButton {
                    dismiss()
                }
            }
        }
        .task {
            mapPosition = createMapPosition(place.location)
            await fetchSightsAndEateries(place)

            // seed prevCurrentLocation
            prevCurrentLocation = locationManager.location
        }
        .sheet(item: $tappedCardPlace) { identifiablePlace in
            MapViewControllerRepresentable(place: identifiablePlace.place)
        }
        .onChange(of: locationManager.location) { _ , currentLocation in
            if let currentLocation = currentLocation, currentLocationButtonTapped {
                prevCurrentLocation = currentLocation
                Task {
                    do {
                        try await updateToCurrentCity(currentLocation)
                        await fetchSightsAndEateries(place)
                    } catch {
                        // handle error
                    }
                }
            } else {
                print("current location is nil")
            }
        }
    }
    
    private func fetchSightsAndEateries(_ city: Place) async -> Void {
        guard let placeId = city.placeID else { return }
        do {
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            sights = try await API.PlaceSearch.fetchPlacesFor(placeId: placeId, type: .sights, maxResultCount: isIpad ? 12 : 7)
            eateries = try await API.PlaceSearch.fetchPlacesFor(placeId: placeId, type: .eateries, maxResultCount: isIpad ? 12 : 7)
        } catch {
            return
        }
    }
    
    private func updateToCurrentCity(_ location: CLLocationCoordinate2D) async throws -> Void {
        let (currentPlace, currentImage) = try await API.PlaceSearch.fetchCurrentCityBy(location)
        place = currentPlace
        image = currentImage
        mapPosition = createMapPosition(place.location)
    }
    
    private func createMapPosition(_ location: CLLocationCoordinate2D) -> MapCameraPosition {
        .region(MKCoordinateRegion(center: place.location, span: .init(latitudeDelta: 0.07, longitudeDelta: 0.07)))
    }
}
