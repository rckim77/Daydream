import CoreLocation
import Testing
@testable import Daydream

@Suite("Current city requests")
@MainActor
struct CurrentCityRequestStateTests {
    private let city = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)

    @Test("A repeated coordinate after the tap completes a fresh request")
    func locationArrivesBeforeTap() {
        let state = CurrentCityRequestState()
        // Passive delivery must not navigate; a repeated equal value need not emit onChange.
        #expect(state.receive(city) == nil)
        state.begin()
        #expect(state.receive(city) == city)
        #expect(state.receive(city) == nil)
        #expect(!state.isWaitingForLocation)
    }

    @Test("The first authorized delivery completes a pending tap only once")
    func locationArrivesAfterTap() {
        let state = CurrentCityRequestState()
        state.begin()
        #expect(state.receive(nil) == nil)
        #expect(state.isWaitingForLocation)
        #expect(state.receive(city) == city)
        #expect(state.receive(CLLocationCoordinate2D(latitude: 48.85, longitude: 2.35)) == nil)
    }

    @Test("A failed request stops waiting and allows another tap")
    func failedRequestCanRetry() {
        let state = CurrentCityRequestState()
        state.begin()
        #expect(state.cancel())
        #expect(state.receive(city) == nil)
        #expect(!state.cancel())
        state.begin()
        #expect(state.receive(city) == city)
    }
}
