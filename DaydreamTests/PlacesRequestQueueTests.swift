import Testing
@testable import Daydream

@Suite("Places request scheduling")
@MainActor
struct PlacesRequestQueueTests {
    @Test("A second operation waits until the first has completed")
    func serialOperations() async throws {
        let queue = PlacesRequestQueue()
        var releaseFirst: CheckedContinuation<Void, Never>?
        var events: [String] = []
        let (started, signal) = AsyncStream<Void>.makeStream()
        let first = Task {
            try await queue.run {
                events.append("first started")
                await withCheckedContinuation { continuation in
                    releaseFirst = continuation
                    signal.yield(())
                }
                events.append("first finished")
            }
        }
        var iterator = started.makeAsyncIterator()
        await iterator.next()
        let (secondStarted, secondSignal) = AsyncStream<Void>.makeStream()
        let second = Task {
            secondSignal.yield(())
            try await queue.run { events.append("second") }
        }
        var secondIterator = secondStarted.makeAsyncIterator()
        await secondIterator.next()
        #expect(events == ["first started"])
        releaseFirst?.resume()
        try await first.value
        try await second.value
        #expect(events == ["first started", "first finished", "second"])
    }

    @Test("A cancelled waiting operation never starts and does not block its successor")
    func cancelledWaiter() async throws {
        let queue = PlacesRequestQueue()
        var releaseFirst: CheckedContinuation<Void, Never>?
        var cancelledOperationRan = false
        let (started, signal) = AsyncStream<Void>.makeStream()
        let first = Task {
            try await queue.run {
                await withCheckedContinuation { continuation in
                    releaseFirst = continuation
                    signal.yield(())
                }
            }
        }
        var iterator = started.makeAsyncIterator()
        await iterator.next()
        let (queued, queuedSignal) = AsyncStream<Void>.makeStream()
        let cancelled = Task {
            queuedSignal.yield(())
            try await queue.run { cancelledOperationRan = true }
        }
        var queuedIterator = queued.makeAsyncIterator()
        await queuedIterator.next()
        cancelled.cancel()
        let successor = Task { try await queue.run { 42 } }
        releaseFirst?.resume()
        try await first.value
        do {
            try await cancelled.value
            Issue.record("The cancelled operation should throw CancellationError")
        } catch {
            #expect(error is CancellationError)
        }
        #expect(!cancelledOperationRan)
        #expect(try await successor.value == 42)
    }
}
