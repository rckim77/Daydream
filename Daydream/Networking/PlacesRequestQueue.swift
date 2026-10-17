import Foundation

/// Run Nearby requests one at a time while investigating crashes during SDK request teardown.
@MainActor
final class PlacesRequestQueue {
    private var isRunning = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func run<Value>(_ operation: @MainActor () async -> Value) async throws -> Value {
        if isRunning {
            await withCheckedContinuation { waiters.append($0) }
        } else {
            isRunning = true
        }
        defer {
            if waiters.isEmpty {
                isRunning = false
            } else {
                waiters.removeFirst().resume()
            }
        }
        // Cancelled queued work must release its turn without starting another SDK request.
        try Task.checkCancellation()
        return await operation()
    }
}
