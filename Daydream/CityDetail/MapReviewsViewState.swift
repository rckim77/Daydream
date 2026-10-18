import Foundation
import Observation

/// Own the identity of the displayed SDK request so a previous selection cannot update the overlay.
@MainActor
@Observable
final class MapReviewsViewState {
    private(set) var placeID: String?
    private(set) var placeName = ""
    private(set) var requestID = UUID()
    private(set) var loadFailed = false
    private(set) var hasLoaded = false

    func select(placeID: String, name: String) {
        placeName = name
        guard self.placeID != placeID else { return }
        self.placeID = placeID
        retry()
    }

    func retry() {
        requestID = UUID()
        loadFailed = false
        hasLoaded = false
    }

    @discardableResult
    func complete(requestID: UUID, failed: Bool) -> Bool {
        guard self.requestID == requestID else { return false }
        loadFailed = failed
        hasLoaded = !failed
        return true
    }
}
