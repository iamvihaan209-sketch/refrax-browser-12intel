import AppKit
import Combine

/// Tracks the current state of keyboard modifier keys.
///
/// This class monitors modifier key changes using `NSEvent.addLocalMonitorForEvents`
/// and exposes the state as `@Observable` properties for SwiftUI reactivity.
///
/// ## Usage
///
/// ```swift
/// // In your app's environment setup
/// @State private var modifierKeys = ModifierKeysState()
///
/// ContentView()
///     .environmentObject(modifierKeys)
///
/// // In a view
/// @EnvironmentObject private var modifierKeys: ModifierKeysState
///
/// if modifierKeys.isOptionPressed {
///     // Option key is pressed
/// }
/// ```
final class ModifierKeysState: ObservableObject {
    // MARK: - State

    /// Whether the Option (Alt) key is currently pressed.
    @Published private(set) var isOptionPressed: Bool = false

    /// Whether the Command key is currently pressed.
    @Published private(set) var isCommandPressed: Bool = false

    /// Whether the Shift key is currently pressed.
    @Published private(set) var isShiftPressed: Bool = false

    /// Whether the Control key is currently pressed.
    @Published private(set) var isControlPressed: Bool = false

    // MARK: - Private

    private nonisolated(unsafe) var monitor: Any?

    // MARK: - Initialization

    init() {
        startMonitoring()
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        // Set initial state
        updateFromFlags(NSEvent.modifierFlags)

        // Monitor for modifier key changes
        monitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.updateFromFlags(event.modifierFlags)
            return event
        }
    }

    deinit {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    private func stopMonitoring() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
    }

    private func updateFromFlags(_ flags: NSEvent.ModifierFlags) {
        isOptionPressed = flags.contains(.option)
        isCommandPressed = flags.contains(.command)
        isShiftPressed = flags.contains(.shift)
        isControlPressed = flags.contains(.control)
    }
}
