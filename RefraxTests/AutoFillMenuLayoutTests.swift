import AppKit
import SwiftUI
import Testing

@testable import Refrax

// The menu is laid out in an overlay that proposes the whole content area, so any greedy
// child grows to fill whatever cap it has. These tests measure the credential list under
// that kind of proposal.

@MainActor
@Suite("AutoFillCredentialList layout", .tags(.autoFillManager))
struct AutoFillCredentialListLayoutTests {
    private static let overlayProposal = CGSize(width: 1200, height: 900)
    private static let rowHeight: CGFloat = 44

    private func credentials(_ count: Int) -> ArraySlice<PasswordsManager.StoredCredential> {
        (0 ..< count).map {
            PasswordsManager.StoredCredential(domain: "example.com", username: "user\($0)@example.com", password: "pw\($0)")
        }[...]
    }

    private func measuredHeight(of view: some View) -> CGFloat {
        let controller = NSHostingController(rootView: view.frame(width: 300))
        return controller.sizeThatFits(in: Self.overlayProposal).height
    }

    @Test("No credentials take no height")
    func emptyListCollapses() {
        let height = measuredHeight(of: AutoFillCredentialList(credentials: credentials(0)) { _ in })
        #expect(height == 0)
    }

    @Test("A few credentials size to their rows", arguments: [1, 3, 6])
    func shortListSizesToRows(count: Int) {
        let height = measuredHeight(of: AutoFillCredentialList(credentials: credentials(count)) { _ in })
        let expected = CGFloat(count) * Self.rowHeight + CGFloat(count - 1) * AutoFillCredentialList.Constants.itemSpacing
        #expect(abs(height - expected) < 1)
    }

    @Test("A long list scrolls at the fixed height")
    func longListScrolls() {
        let height = measuredHeight(of: AutoFillCredentialList(credentials: credentials(20)) { _ in })
        #expect(height == AutoFillCredentialList.Constants.scrollingHeight)
    }
}
