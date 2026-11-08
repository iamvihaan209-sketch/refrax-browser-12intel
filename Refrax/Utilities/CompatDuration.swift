import Foundation

/// Stand-in for `Duration` (macOS 13+) so durations compile on macOS 12.
struct CompatDuration: Sendable, Equatable, Comparable, Hashable {
    var nanoseconds: UInt64

    static func seconds(_ value: Int) -> CompatDuration { CompatDuration(nanoseconds: UInt64(max(value, 0)) * 1_000_000_000) }
    static func seconds(_ value: Double) -> CompatDuration { CompatDuration(nanoseconds: UInt64(max(value, 0) * 1_000_000_000)) }
    static func milliseconds(_ value: Int) -> CompatDuration { CompatDuration(nanoseconds: UInt64(max(value, 0)) * 1_000_000) }

    static func < (lhs: CompatDuration, rhs: CompatDuration) -> Bool { lhs.nanoseconds < rhs.nanoseconds }

    /// Seconds as a `Double`, matching `Duration`'s `/` operator with a `Duration`.
    var timeInterval: TimeInterval { TimeInterval(nanoseconds) / 1_000_000_000 }

    static func / (lhs: CompatDuration, rhs: CompatDuration) -> Double {
        Double(lhs.nanoseconds) / Double(rhs.nanoseconds)
    }
}

extension Task where Success == Never, Failure == Never {
    /// Sleeps for a `CompatDuration`, so `Task.sleep(for:)` call sites compile on macOS 12.
    static func sleep(for duration: CompatDuration) async throws {
        try await Task<Never, Never>.sleep(nanoseconds: duration.nanoseconds)
    }
}
