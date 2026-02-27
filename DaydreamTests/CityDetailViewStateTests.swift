import CoreLocation
import Testing
import UIKit

@testable import Daydream

@Suite("CityDetailViewState")
@MainActor
struct CityDetailViewStateTests {

    final class PlaceFetchRecorder {
        var calls = [(placeId: String, type: API.PlaceSearch.PlaceSearchType, maxCount: Int)]()
    }

    @Test("city text appends country flag emoji when country code exists")
    func cityTextIncludesCountryFlag() {
        let viewState = CityDetailViewState()

        let text = viewState.cityText(displayName: "New York", countryCode: "US")

        #expect(text == "New York 🇺🇸")
    }

    @Test("city text omits flag when country code is missing or invalid")
    func cityTextWithoutCountryCode() {
        let viewState = CityDetailViewState()

        #expect(viewState.cityText(displayName: "Paris", countryCode: nil) == "Paris")
        #expect(viewState.cityText(displayName: "Paris", countryCode: "FRA") == "Paris")
    }

    @Test("review request only occurs for new versions after enough review views")
    func reviewDecisionLogic() {
        let viewState = CityDetailViewState()

        let notEnoughViews = viewState.makeReviewRequestDecision(
            appVersion: "4.5.0",
            reviewsViewedCount: 1,
            lastReviewedAppVersion: "4.4.0"
        )
        #expect(notEnoughViews.shouldRequestReview == false)

        let alreadyReviewedVersion = viewState.makeReviewRequestDecision(
            appVersion: "4.5.0",
            reviewsViewedCount: 3,
            lastReviewedAppVersion: "4.5.0"
        )
        #expect(alreadyReviewedVersion.shouldRequestReview == false)

        let shouldReview = viewState.makeReviewRequestDecision(
            appVersion: "4.5.1",
            reviewsViewedCount: 3,
            lastReviewedAppVersion: "4.5.0"
        )
        #expect(shouldReview.shouldRequestReview == true)
        #expect(shouldReview.updatedLastReviewedAppVersion == "4.5.1")
    }

    @Test("max result count adapts to idiom")
    func maxResultCountByDeviceIdiom() {
        let viewState = CityDetailViewState()

        #expect(viewState.maxResultCount(for: .phone) == 7)
        #expect(viewState.maxResultCount(for: .pad) == 12)
    }

    @Test("current location immediate update is gated by previous coordinate equality")
    func currentLocationImmediateUpdateGating() {
        let viewState = CityDetailViewState()
        let current = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        viewState.seedPreviousCurrentLocation(current)
        #expect(viewState.currentLocationToLoadImmediately(currentLocation: current) == current)

        let different = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        #expect(viewState.currentLocationToLoadImmediately(currentLocation: different) == nil)
    }

    @Test("loads both sights and eateries with idiom-specific max count")
    func loadSightsAndEateriesRequestsBothTypes() async {
        let viewState = CityDetailViewState()
        let recorder = PlaceFetchRecorder()

        await viewState.loadSightsAndEateries(placeId: "place-123", idiom: .pad) { placeId, type, maxCount in
            recorder.calls.append((placeId: placeId, type: type, maxCount: maxCount))
            return []
        }

        #expect(recorder.calls.count == 2)
        #expect(recorder.calls[0].placeId == "place-123")
        #expect(recorder.calls[0].type == .sights)
        #expect(recorder.calls[0].maxCount == 12)
        #expect(recorder.calls[1].type == .eateries)
        #expect(recorder.calls[1].maxCount == 12)
        #expect(viewState.sights.isEmpty)
        #expect(viewState.eateries.isEmpty)
    }

    @Test("skips place loading when place ID is missing")
    func loadSightsAndEateriesSkipsWhenPlaceIdMissing() async {
        let viewState = CityDetailViewState()
        let recorder = PlaceFetchRecorder()

        await viewState.loadSightsAndEateries(placeId: nil, idiom: .phone) { placeId, type, maxCount in
            recorder.calls.append((placeId: placeId, type: type, maxCount: maxCount))
            return []
        }

        #expect(recorder.calls.isEmpty)
    }
}
