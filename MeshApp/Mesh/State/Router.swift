import SwiftUI

final class AppState: ObservableObject {
    @Published var storage: [String: MeshState] = [:]
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

        let debug: String = {
            switch style {
            case .fullscreen:
                return "Fullscreen"
            case .modal:
                return "Modal"
            case .sheet:
                return "Sheet"
            case .push, .none:
                return "Push"
            }
        }()

        print("[Router] \(debug) \(id).")
        presenters.last?.present(screen: screen, style: style ?? .push)
    }

    func pushPresenter(_ presenter: Presenter) {
        print("[Router] Push Presenter.")
        presenters.append(presenter)
    }

    func popPresenter() {
        print("[Router] Pop Presenter.")
        presenters = presenters.dropLast()
    }
}

enum PresentationStyle {
    case modal
    case push
    case sheet
    case fullscreen
}

protocol Presenter {
    func present(screen: MeshScreen, style: PresentationStyle)
}
