#if REFRAX_NO_EXTENSIONS
import Foundation

/// Stand-ins used only by the Monterey build, where WebKit extensions are excluded.
/// Every lookup finds nothing, so the browser runs as if no extensions are installed.
final class ExtensionManager: ObservableObject {
    struct ContextStub {
        var baseURL: URL?
    }

    func extensionContext(for url: URL) -> ContextStub? { nil }
}

enum ExtensionPageRouting {
    static let scheme = "webkit-extension"
    static func canNavigate(from _: URL?, to _: URL?) -> Bool { true }
}

final class ExtensionCommandHandler {
    init(extensionManager _: ExtensionManager) {}
}
#endif
