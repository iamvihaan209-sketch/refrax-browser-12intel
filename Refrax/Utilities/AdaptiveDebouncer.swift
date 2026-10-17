import Foundation

/// Debounces actions with adaptive delay based on typing speed and input length.
///
/// Uses monotonic uptime nanoseconds instead of ContinuousClock/Duration so the
/// timing implementation remains available on macOS 12.
@MainActor
final class AdaptiveDebouncer {
    private var task: Task<Void, Never>?
    private var lastKeystrokeNanoseconds: UInt64?

    private enum Thresholds {
        static let singleChar: UInt64 = 350_000_000
        static let twoChars: UInt64 = 200_000_000
        static let threeOrMore: UInt64 = 100_000_000
        static let fastTypingInterval: UInt64 = 150_000_000
        static let slowTypingInterval: UInt64 = 400_000_000
        static let minDelay: UInt64 = 50_000_000
        static let maxDelay: UInt64 = 400_000_000
    }

    /// Cancels any pending action and schedules a new one with adaptive delay.
    func debounce(for input: String, action: @escaping @MainActor () async -> Void) {
        task?.cancel()

        let now = DispatchTime.now().uptimeNanoseconds
        let keystrokeInterval = lastKeystrokeNanoseconds.map { now >= $0 ? now - $0 : 0 }
        lastKeystrokeNanoseconds = now

        let delay = calculateDelay(inputLength: input.count, keystrokeInterval: keystrokeInterval)

        task = Task {
            try? await Task.sleep(nanoseconds: delay)
            guard !Task.isCancelled else { return }
            await action()
        }
    }

    /// Cancels any pending action and resets typing speed tracking.
    func cancel() {
        task?.cancel()
        task = nil
        lastKeystrokeNanoseconds = nil
    }

    /// Calculates adaptive delay based on input length and typing speed.
    private func calculateDelay(inputLength: Int, keystrokeInterval: UInt64?) -> UInt64 {
        let baseDelay: UInt64
        switch inputLength {
        case 0: baseDelay = 0
        case 1: baseDelay = Thresholds.singleChar
        case 2: baseDelay = Thresholds.twoChars
        default: baseDelay = Thresholds.threeOrMore
        }

        guard inputLength > 0 else { return 0 }
        guard let interval = keystrokeInterval else { return baseDelay }

        let multiplier: Double
        if interval < Thresholds.fastTypingInterval {
            multiplier = 1.5
        } else if interval > Thresholds.slowTypingInterval {
            multiplier = 0.5
        } else {
            multiplier = 1.0
        }

        let adjusted = UInt64(Double(baseDelay) * multiplier)
        return min(max(adjusted, Thresholds.minDelay), Thresholds.maxDelay)
    }
}
