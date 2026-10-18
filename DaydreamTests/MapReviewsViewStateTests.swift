import Testing
@testable import Daydream

@Suite("Map reviews selection")
@MainActor
struct MapReviewsViewStateTests {
    @Test("The overlay waits for a selection")
    func initialState() {
        let state = MapReviewsViewState()
        #expect(state.placeID == nil)
        #expect(!state.loadFailed)
    }

    @Test("A new place resets a failure and changes request identity")
    func selectionChanges() {
        let state = MapReviewsViewState()
        state.select(placeID: "first", name: "First")
        let firstRequest = state.requestID
        #expect(state.complete(requestID: firstRequest, failed: true))
        state.select(placeID: "second", name: "Second")
        #expect(state.placeID == "second")
        #expect(state.placeName == "Second")
        #expect(state.requestID != firstRequest)
        #expect(!state.loadFailed)
    }

    @Test("Late callbacks from an earlier place or retry cannot change current state")
    func staleCallbacks() {
        let state = MapReviewsViewState()
        state.select(placeID: "first", name: "First")
        let firstRequest = state.requestID
        state.select(placeID: "second", name: "Second")
        #expect(!state.complete(requestID: firstRequest, failed: true))
        let secondRequest = state.requestID
        state.retry()
        #expect(!state.complete(requestID: secondRequest, failed: true))
        #expect(!state.loadFailed)
        #expect(state.complete(requestID: state.requestID, failed: true))
        state.retry()
        #expect(!state.loadFailed)
    }

    @Test("Selecting the same place does not issue another component request")
    func unchangedSelection() {
        let state = MapReviewsViewState()
        state.select(placeID: "first", name: "First")
        let request = state.requestID
        state.select(placeID: "first", name: "Updated name")
        #expect(state.requestID == request)
        #expect(state.placeName == "Updated name")
    }
}
