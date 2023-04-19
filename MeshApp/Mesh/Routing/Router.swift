import SwiftUI

/*
 1. Push / Modal / Sheet
 */

/*
 Mesh Router
 1. Modal
    - need access
 2. Sheet
 3. Push
 */

final class Router: ObservableObject {
    @Published var screens: [MeshScreen]
    private var presenters: [Presenter] = []

    init(screens: [MeshScreen]) {
        self.screens = screens
    }

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

        presenters.last?.present(screen: screen, style: style ?? .push)
    }

    func pushModalPresenter(_ presenter: Presenter) {
        presenters.append(presenter)
    }

    func popModalPresenter() {
        presenters = presenters.dropLast(1)
    }
}

enum PresentationStyle {
    case modal
    case push
    case sheet
}

protocol Presenter {
    func present(screen: MeshScreen, style: PresentationStyle)
}
