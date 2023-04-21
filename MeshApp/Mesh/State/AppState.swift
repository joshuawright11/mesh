import SwiftUI

/// There are one of these per Mesh App. Use this to keep track of global state
/// and route between screens.
final class AppState: ObservableObject {
    @Published var storage: [String: StateItem] = [:]
    @Published var screens: [MeshScreen]

    private var presenters: [Presenter] = []

    init(screens: [MeshScreen]) {
        self.screens = screens
    }

    // MARK: Routing

    func screen(for id: String) -> MeshScreen? {
        guard let screen = screens.first(where: { $0.id == id }) else {
            print("[Router] Unable to present screen with unknown id \(id).")
            return nil
        }

        return screen
    }

    func present(id: String, style: PresentationStyle? = nil) {
        guard let screen = screen(for: id) else {
            return
        }

        print("[Router] Present `\(id)` \(style ?? .push).")
        presenters.last?.present(screen: screen, style: style ?? .push)
    }

    func pushPresenter(_ presenter: Presenter) {
        print("[Router] Push Presenter.")
        presenters.append(presenter)
    }

    /// TODO investigate presenting instant pop/push animation after background / foregrounding? (via open url or changing tabs)
    func popPresenter() {
        print("[Router] Pop Presenter.")
        presenters = presenters.dropLast()
    }

    func openURL(_ url: URL) {
        presenters.last?.openURL(url)
    }

    /// This default behavior of this function depends on the router state:
    ///
    /// 0. If a sheet is active, it will be dismissed.
    /// 1. Otherwise, if the current navigation stack is more than 1, the top view will be
    ///    popped.
    /// 2. Otherwise, the top modally presented view will be dismissed.
    ///
    /// You may pass the `modal` parameter to force this function to pop the
    /// top modal view, if one exists.
    func dismiss(modal: Bool = false) {
        presenters.last?.dismiss(modal: modal)
    }
}
