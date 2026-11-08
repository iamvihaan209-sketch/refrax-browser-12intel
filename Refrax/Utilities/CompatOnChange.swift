import SwiftUI

/// Two-value `onChange` for macOS 12. On older systems the previous value is tracked in state.
private struct CompatChangeModifier<V: Equatable>: ViewModifier {
    let value: V
    let initial: Bool
    let action: (V, V) -> Void

    @State private var previous: V?

    func body(content: Content) -> some View {
        content
            .onAppear {
                previous = value
                if initial { action(value, value) }
            }
            .onChange(of: value) { new in
                let old = previous ?? new
                previous = new
                action(old, new)
            }
    }
}

extension View {
    /// Mirrors macOS 14's `onChange(of:initial:_:)` on macOS 12.
    func compatOnChange<V: Equatable>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (V, V) -> Void
    ) -> some View {
        modifier(CompatChangeModifier(value: value, initial: initial, action: action))
    }
}
