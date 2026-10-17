import CoreLocation
import Testing
@testable import Daydream

@Suite("Location delivery")
@MainActor
struct CurrentLocationManagerTests {
    final class LocationManagerSpy: CLLocationManager {
        var status: CLAuthorizationStatus = .notDetermined
        var locationRequests = 0
        var authorizationRequests = 0
        override var authorizationStatus: CLAuthorizationStatus { status }
        override func requestLocation() { locationRequests += 1 }
        override func requestWhenInUseAuthorization() { authorizationRequests += 1 }
    }

    @Test("Fresh identical fixes emit distinct delivery events and satisfy a tap once")
    func repeatedCoordinateDelivery() {
        let spy = LocationManagerSpy()
        let manager = CurrentLocationManager(manager: spy)
        let request = CurrentCityRequestState()
        let city = CLLocation(latitude: 40.7128, longitude: -74.006)
        manager.locationManager(spy, didUpdateLocations: [city])
        let previousDelivery = manager.locationUpdateCount
        #expect(request.receive(manager.location) == nil)
        spy.status = .authorizedWhenInUse
        request.begin()
        #expect(manager.requestCurrentLocation() == .authorizedWhenInUse)
        #expect(spy.locationRequests == 1)
        manager.locationManager(spy, didUpdateLocations: [city])
        #expect(manager.locationUpdateCount == previousDelivery + 1)
        #expect(request.receive(manager.location) == city.coordinate)
        #expect(request.receive(manager.location) == nil)
    }

    @Test("Both existing authorized modes request a fix; undetermined requests permission")
    func authorizationModes() {
        let spy = LocationManagerSpy()
        let manager = CurrentLocationManager(manager: spy)
        for status in [CLAuthorizationStatus.authorizedWhenInUse, .authorizedAlways] {
            spy.status = status
            #expect(manager.requestCurrentLocation() == status)
        }
        #expect(spy.locationRequests == 2)
        spy.status = .notDetermined
        #expect(manager.requestCurrentLocation() == .notDetermined)
        #expect(spy.authorizationRequests == 1)
        for status in [CLAuthorizationStatus.denied, .restricted] {
            spy.status = status
            #expect(manager.requestCurrentLocation() == status)
        }
        #expect(spy.locationRequests == 2)
    }

    @Test("Location errors publish a failure event so a pending view can stop waiting")
    func failedDelivery() {
        let spy = LocationManagerSpy()
        let manager = CurrentLocationManager(manager: spy)
        let request = CurrentCityRequestState()
        request.begin()
        let previousFailures = manager.requestFailureCount
        manager.locationManager(spy, didFailWithError: CLError(.locationUnknown))
        #expect(manager.requestFailureCount == previousFailures + 1)
        #expect(request.cancel())
        #expect(!request.isWaitingForLocation)
    }
}
