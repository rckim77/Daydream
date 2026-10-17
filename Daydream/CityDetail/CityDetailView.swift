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
    @State var image: UIImage?
    @State private var viewState = CityDetailViewState()

    // MARK: - Environment and AppStorage vars
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    @Environment(CurrentLocationManager.self) private var locationManager
    @AppStorage("reviewsViewedCount") private var reviewsViewedCount: Int = 0
    @AppStorage("lastReviewedAppVersion") private var lastReviewedAppVersion: String = ""

    // MARK: - Computed vars
    private var cityText: String {
        let countryCode = place.addressComponents?
            .first(where: { $0.types.contains(.country) })?
            .shortName
        return viewState.cityText(displayName: place.displayName, countryCode: countryCode)
    }

    var body: some View {
        NavigationStack {
            CityDetailContentView(place: place, cityText: cityText, viewState: viewState)
            .background {
                Rectangle()
                    .fill(.regularMaterial)
                    .background {
                        if let image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .blur(radius: 36, opaque: true)
                        }
                    }
                    .clipped()
                    .ignoresSafeArea()
            }
            .toolbar {
                SearchToolbar { autocompletePlace, autocompleteImage in
                    place = autocompletePlace
                    image = autocompleteImage
                    viewState.applySelectedCity(place)
                    Task {
                        await fetchSightsAndEateries(place)
                    }
                } randomCityReceived: { randomPlace, randomImage in
                    place = randomPlace
                    image = randomImage
                    viewState.applySelectedCity(place)
                    Task {
                        await fetchSightsAndEateries(place)
                    }
                } currentLocationTapped: {
                    viewState.currentCityRequest.begin()
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
            .onChange(of: locationManager.authStatus) { _, status in
                if status == .denied || status == .restricted { viewState.currentCityRequest.cancel() }
            }
            .onChange(of: locationManager.requestFailureCount) { _, _ in
                if viewState.currentCityRequest.cancel() { viewState.showErrorAlert = true }
            }
            .onDisappear { viewState.currentCityRequest.cancel() }
            .onChange(of: locationManager.locationUpdateCount) { _, _ in
                if let currentLocation = viewState.currentCityRequest.receive(locationManager.location) {
                    Task {
                        do {
                            try await updateToCurrentCity(currentLocation)
                        } catch {
                            viewState.showErrorAlert = true
                        }
                    }
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
        let (currentPlace, currentImage) = try await API.PlaceSearch.fetchCurrentCityBy(location)
        place = currentPlace
        image = currentImage
        viewState.applySelectedCity(place)
        await fetchSightsAndEateries(place)
    }
}
