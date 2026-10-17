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
    @Test("A burst of cancelled waiters drains in order and leaves the queue usable")
    func cancellationBurst() async throws {
        let queue = PlacesRequestQueue()
        let (started, signal) = AsyncStream<Void>.makeStream()
        var releaseFirst: CheckedContinuation<Void, Never>?
        var completed: [Int] = []
        var arrivalOrder: [Int] = []
        let first = Task {
            try await queue.run {
                await withCheckedContinuation { continuation in
                    releaseFirst = continuation
                    signal.yield(())
                }
            }
        }
        var startedIterator = started.makeAsyncIterator()
        await startedIterator.next()
        let (queued, queuedSignal) = AsyncStream<Void>.makeStream()
        let jobs = (1...20).map { index in
            Task {
                arrivalOrder.append(index)
                queuedSignal.yield(())
                return try await queue.run {
                    completed.append(index)
                    return index
                }
            }
        }
        var queuedIterator = queued.makeAsyncIterator()
        for _ in jobs { await queuedIterator.next() }
        for (index, job) in jobs.enumerated() where index.isMultiple(of: 2) { job.cancel() }
        releaseFirst?.resume()
        try await first.value
        for (index, job) in jobs.enumerated() {
            do {
                let value = try await job.value
                #expect(!index.isMultiple(of: 2))
                #expect(value == index + 1)
            } catch {
                #expect(index.isMultiple(of: 2))
                #expect(error is CancellationError)
            }
        }
        #expect(completed == arrivalOrder.filter { $0.isMultiple(of: 2) })
        #expect(try await queue.run { 42 } == 42)
    }

}
