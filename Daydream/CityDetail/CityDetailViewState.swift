//
//  CityDetailViewState.swift
//  Daydream
//
//  Created by Codex on 2/27/26.
//

import CoreLocation
import Foundation
import GooglePlacesSwift
import MapKit
import Observation
import SwiftUI
import UIKit

@MainActor
@Observable
final class CityDetailViewState {

    struct ReviewRequestDecision {
        let shouldRequestReview: Bool
        let updatedLastReviewedAppVersion: String?
    }

    var sights = [Place]()
    var eateries = [Place]()
    var mapPosition: MapCameraPosition = .automatic
    var tappedCardPlace: IdentifiablePlace?
    var tappedSheetPlace: IdentifiablePlace?
    var showErrorAlert = false
    var wishlistSourceCity: RandomCity?

    init(wishlistSourceCity: RandomCity? = nil) {
        self.wishlistSourceCity = wishlistSourceCity
    }

    /// This ensures navigation to current location city is gated behind user interaction.
    var currentLocationButtonTapped = false
    var prevCurrentLocation: CLLocationCoordinate2D?

    func cityText(displayName: String?, countryCode: String?) -> String {
        var text = displayName ?? ""

        if let flag = flagEmoji(for: countryCode) {
            text += " " + flag
        }

        return text
    }

    func makeReviewRequestDecision(
        appVersion: String?,
        reviewsViewedCount: Int,
        lastReviewedAppVersion: String
    ) -> ReviewRequestDecision {
        guard let appVersion,
              appVersion != lastReviewedAppVersion,
              reviewsViewedCount > 1 else {
            return ReviewRequestDecision(shouldRequestReview: false, updatedLastReviewedAppVersion: nil)
        }

        return ReviewRequestDecision(shouldRequestReview: true, updatedLastReviewedAppVersion: appVersion)
    }

    func createMapPosition(_ location: CLLocationCoordinate2D) -> MapCameraPosition {
        .region(MKCoordinateRegion(center: location, span: .init(latitudeDelta: 0.07, longitudeDelta: 0.07)))
    }

    func applySelectedCity(_ place: Place, wishlistSourceCity: RandomCity? = nil) {
        mapPosition = createMapPosition(place.location)
        self.wishlistSourceCity = wishlistSourceCity
    }

    func presentMap(_ place: IdentifiablePlace?, asSheet: Bool) {
        // Capture the route at selection so resizing does not replace an open map presentation.
        tappedSheetPlace = asSheet ? place : nil
        tappedCardPlace = asSheet ? nil : place
    }

    func markCurrentLocationTapped() {
        currentLocationButtonTapped = true
    }

    func seedPreviousCurrentLocation(_ location: CLLocationCoordinate2D?) {
        prevCurrentLocation = location
    }

    func currentLocationToLoadImmediately(currentLocation: CLLocationCoordinate2D?) -> CLLocationCoordinate2D? {
        guard let prevCurrentLocation,
              currentLocation == prevCurrentLocation else {
            return nil
        }

        return prevCurrentLocation
    }

    func shouldHandleLocationChange(_ currentLocation: CLLocationCoordinate2D?) -> Bool {
        currentLocation != nil && currentLocationButtonTapped
    }

    func loadSightsAndEateries(
        placeId: String?,
        fetchPlaces: (String, API.PlaceSearch.PlaceSearchType, Int) async throws -> [Place]
    ) async {
        guard let placeId else {
            return
        }

        // Keep the same results when folding; presentation width must not change the data set.
        let maxResultCount = 12

        do {
            sights = try await fetchPlaces(placeId, .sights, maxResultCount)
            eateries = try await fetchPlaces(placeId, .eateries, maxResultCount)
        } catch {
            return
        }
    }

    private func flagEmoji(for countryCode: String?) -> String? {
        guard let countryCode, countryCode.count == 2 else {
            return nil
        }

        let base = 127397
        var unicodeScalars = String.UnicodeScalarView()

        for scalar in countryCode.uppercased().unicodeScalars {
            guard let flagScalar = Unicode.Scalar(base + Int(scalar.value)) else {
                return nil
            }
            unicodeScalars.append(flagScalar)
        }

        return String(unicodeScalars)
    }
}
