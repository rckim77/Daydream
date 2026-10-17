import CoreLocation
import Observation

/// Consume one fresh delivery per user action, even when its coordinate has not changed.
@MainActor
@Observable
final class CurrentCityRequestState {
    private(set) var isWaitingForLocation = false

    func begin() {
        isWaitingForLocation = true
    }

    func receive(_ location: CLLocationCoordinate2D?) -> CLLocationCoordinate2D? {
        guard isWaitingForLocation, let location else { return nil }
        isWaitingForLocation = false
        return location
    }

    @discardableResult
    func cancel() -> Bool {
        let wasWaiting = isWaitingForLocation
        isWaitingForLocation = false
        return wasWaiting
    }
}
