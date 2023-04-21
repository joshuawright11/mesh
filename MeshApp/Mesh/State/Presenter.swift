import Foundation

/// Delegates presenting screens.
protocol Presenter {
    func present(screen: MeshScreen, style: PresentationStyle)
    func openURL(_ url: URL)
}

enum PresentationStyle: CustomDebugStringConvertible {
    case modal
    case push
    case sheet
    case fullscreen

    var debugDescription: String {
        switch self {
        case .fullscreen:
            return "Fullscreen"
        case .modal:
            return "Modal"
        case .sheet:
            return "Sheet"
        case .push:
            return "Push"
        }
    }
}
