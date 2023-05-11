import SwiftUI

// STATE
// 1. App State - One Per App
// 2. Screen State - One Per Screen
// 3. View State - One Per MeshView

final class ViewState: ObservableObject {
    @Published var storage: [String: StateItem] = [:]

    init(state: [String : StateItem] = [:]) {
        self.storage = state
    }
}

struct ViewView<Content: View>: View {
    @EnvironmentObject var superState: ViewState
    @StateObject var state: ViewState

    let content: () -> Content

    init(state: [String: StateItem] = [:], @ViewBuilder content: @escaping () -> Content) {
        self._state = StateObject(wrappedValue: ViewState(state: state))
        self.content = content
    }

    var body: some View {
        content()
            .environmentObject(state)
            .onAppear {
                state.storage.merge(superState.storage, uniquingKeysWith: { (current, _) in current })
            }
    }
}
