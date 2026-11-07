import SwiftUI

/// Stand-in for macOS 26's `Glass` so call sites compile on older SDK targets.
/// On macOS 26+ it resolves to the real Liquid Glass; earlier systems get a material.
struct CompatGlass {
    var isIdentity = false
    var tint: Color?
    var isInteractive = false

    static var regular: CompatGlass { CompatGlass() }
    static var identity: CompatGlass { CompatGlass(isIdentity: true) }

    func tint(_ color: Color?) -> CompatGlass {
        var copy = self
        copy.tint = color
        return copy
    }

    func interactive() -> CompatGlass {
        var copy = self
        copy.isInteractive = true
        return copy
    }

    @available(macOS 26.0, *)
    fileprivate var resolved: Glass {
        var glass: Glass = isIdentity ? .identity : .regular
        if let tint { glass = glass.tint(tint) }
        if isInteractive { glass = glass.interactive() }
        return glass
    }
}

extension View {
    /// Applies Liquid Glass on macOS 26+, or a material background on older macOS.
    @ViewBuilder
    func compatGlassEffect<S: Shape>(_ glass: CompatGlass = .regular, in shape: S) -> some View {
        if #available(macOS 26.0, *) {
            self.glassEffect(glass.resolved, in: shape)
        } else {
            self.background {
                ZStack {
                    if !glass.isIdentity {
                        shape.fill(.regularMaterial)
                    }
                    if let tint = glass.tint {
                        shape.fill(tint)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func compatGlassEffect(_ glass: CompatGlass = .regular) -> some View {
        compatGlassEffect(glass, in: Capsule())
    }
}
