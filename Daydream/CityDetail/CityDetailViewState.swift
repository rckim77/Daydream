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
    var showErrorAlert = false

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

    func maxResultCount(for idiom: UIUserInterfaceIdiom) -> Int {
        idiom == .pad ? 12 : 7
    }

    func createMapPosition(_ location: CLLocationCoordinate2D) -> MapCameraPosition {
        .region(MKCoordinateRegion(center: location, span: .init(latitudeDelta: 0.07, longitudeDelta: 0.07)))
    }

    func applySelectedCity(_ place: Place) {
        mapPosition = createMapPosition(place.location)
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
        idiom: UIUserInterfaceIdiom,
        fetchPlaces: (String, API.PlaceSearch.PlaceSearchType, Int) async throws -> [Place]
    ) async {
        guard let placeId else {
            return
        }

        let maxResultCount = maxResultCount(for: idiom)

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
