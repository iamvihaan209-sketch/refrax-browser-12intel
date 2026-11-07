import SwiftUI

struct SidebarContentView: View {
    @GestureState var isDraggingWindow = false

    var body: some View {
        if #available(macOS 15.0, *) {
            VStack {
                Sidebar()
            }
            .gesture(dragWindow)
            .allowsWindowActivationEvents()
        } else {
            VStack {
                Sidebar()
            }
        }
    }

    @available(macOS 15.0, *)
    private var dragWindow: some Gesture {
        WindowDragGesture()
            .updating($isDraggingWindow) { _, state, _ in
                state = true
            }
    }
}
