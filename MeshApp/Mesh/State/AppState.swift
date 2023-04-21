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

    /// TODO investigate presenting when background / foregrounding?
    func pushPresenter(_ presenter: Presenter) {
        print("[Router] Push Presenter.")
        presenters.append(presenter)
    }

    func popPresenter() {
        print("[Router] Pop Presenter.")
        presenters = presenters.dropLast()
    }

    func openURL(_ url: URL) {
        presenters.last?.openURL(url)
    }
}
