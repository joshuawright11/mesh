import SwiftUI

/// There are one of these per Mesh Screen.
final class ScreenState: ObservableObject {
    @Published var storage: [String: StateItem] = [:]
}

struct ScreenView<Content: View>: View {
    @StateObject var state = ScreenState()
    @StateObject var viewState = ViewState()

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .environmentObject(state)
            .environmentObject(viewState)
    }
}
