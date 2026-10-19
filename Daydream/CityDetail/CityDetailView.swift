//
//  CityDetailView.swift
//  Daydream
//
//  Created by Ray Kim on 10/14/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import CoreLocation
import SwiftUI
import GooglePlacesSwift
import StoreKit

struct CityDetailView: View {

    // MARK: - State vars
    @State var place: Place
    @State private var viewState = CityDetailViewState()

    // MARK: - Environment and AppStorage vars
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    @Environment(CurrentLocationManager.self) private var locationManager
    @AppStorage("reviewsViewedCount") private var reviewsViewedCount: Int = 0
    @AppStorage("lastReviewedAppVersion") private var lastReviewedAppVersion: String = ""

    // MARK: - Computed vars
    private var countryCode: String? {
        place.addressComponents?
            .first(where: { $0.types.contains(.country) })?
            .shortName
    }

    private var cityText: String {
        viewState.cityText(displayName: place.displayName, countryCode: countryCode)
    }

    var body: some View {
        NavigationStack {
            CityDetailContentView(place: place, cityText: cityText, viewState: viewState)
            .background {
                CountryFlagBackground(countryCode: countryCode)
            }
            .toolbar {
                SearchToolbar { autocompletePlace in
                    place = autocompletePlace
                    viewState.applySelectedCity(place)
                    Task {
                        await fetchSightsAndEateries(place)
                    }
                } randomCityReceived: { randomPlace in
                    place = randomPlace
                    viewState.applySelectedCity(place)
                    Task {
                        await fetchSightsAndEateries(place)
                    }
                } currentLocationTapped: {
                    viewState.markCurrentLocationTapped()
                    guard let currentLocation = viewState.currentLocationToLoadImmediately(currentLocation: locationManager.location) else {
                        // the .onChange(of:) will be triggered and programmatically navigate
                        return
                    }
                    Task {
                        do {
                            try await updateToCurrentCity(currentLocation)
                        } catch {
                            viewState.showErrorAlert = true
                        }
                    }
                } additionalViews: {
                    ToolbarItem(placement: .bottomBar) {
                        HomeButton {
                            dismiss()
                        }
                    }
                }
            }
            .task {
                viewState.applySelectedCity(place)
                await fetchSightsAndEateries(place)
                viewState.seedPreviousCurrentLocation(locationManager.location)
            }
            .sheet(item: $viewState.tappedSheetPlace) { identifiablePlace in
                Group {
                    if #available(iOS 27.0, *) {
                        MapDetailView(place: identifiablePlace.place)
                            .presentationPlacement(.center)
                    } else {
                        MapDetailView(place: identifiablePlace.place)
                    }
                }
                .presentationSizing(.form)
                .presentationCompactAdaptation(.sheet)
            }
            .fullScreenCover(item: $viewState.tappedCardPlace) { identifiablePlace in
                MapDetailView(place: identifiablePlace.place)
            }
            .errorAlert(isPresented: $viewState.showErrorAlert)
            .onChange(of: locationManager.location) { _, currentLocation in
                if viewState.shouldHandleLocationChange(currentLocation) {
                    viewState.seedPreviousCurrentLocation(currentLocation)
                    if let currentLocation {
                        Task {
                            do {
                                try await updateToCurrentCity(currentLocation)
                            } catch {
                                viewState.showErrorAlert = true
                            }
                        }
                    }
                } else {
                    print("current location is nil")
                }
            }
            .onAppear {
                requestReviewIfApplicable()
            }
        }
    }

    /// Note: We only want to request an app review if the user hasn't already reviewed this app version and
    /// has viewed at least 2 reviews from MapCardView.
    private func requestReviewIfApplicable() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let decision = viewState.makeReviewRequestDecision(
            appVersion: appVersion,
            reviewsViewedCount: reviewsViewedCount,
            lastReviewedAppVersion: lastReviewedAppVersion
        )

        if decision.shouldRequestReview,
           let reviewedVersion = decision.updatedLastReviewedAppVersion {
            requestReview()
            print("requested review, storing last reviewed app version: \(reviewedVersion)")
            lastReviewedAppVersion = reviewedVersion
        } else {
            print("review request not applicable")
        }
    }

    private func fetchSightsAndEateries(_ city: Place) async {
        await viewState.loadSightsAndEateries(
            placeId: city.placeID
        ) { placeId, type, maxResultCount in
            try await API.PlaceSearch.fetchPlacesFor(placeId: placeId, type: type, maxResultCount: maxResultCount)
        }
    }

    private func updateToCurrentCity(_ location: CLLocationCoordinate2D) async throws {
        let currentPlace = try await API.PlaceSearch.fetchCurrentCityBy(location)
        place = currentPlace
        viewState.applySelectedCity(place)
        await fetchSightsAndEateries(place)
    }
}
