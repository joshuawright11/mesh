import SwiftUI

/// There are one of these per Mesh App. Use this to keep track of global state
/// and route between screens.
final class AppState: ObservableObject {
    /// Local
    @Published var screens: [MeshScreen]
    @Published var storage: [String: StateItem] = [:]

    // Remote
    @Published var actions: [MeshAction]
    @Published var resources: [MeshResource]

    private var presenters: [Presenter] = []

    init(screens: [MeshScreen], actions: [MeshAction], resources: [MeshResource]) {
        self.screens = screens
        self.actions = actions
        self.resources = resources
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

    // MARK: Actions

    func action(_ id: String, parameters: [String: StateItem]) {
        guard let action = actions.first(where: { $0.id == id }) else {
            print("[Router] Unable to perform action with unknown id \(id).")
            return
        }

        var validatedParameters: [String: StateItem] = [:]
        for (key, type) in action.parameters {
            guard let value = parameters[key] else {
                print("[Actions] Missing parameter `\(key)` for action `\(action.id)`!")
                return
            }

            guard value.matchesType(type) else {
                print("[Actions] Type mismatch of parameter `\(key)` for action `\(action.id)`!")
                return
            }

            validatedParameters[key] = value
        }

        print("[Actions] Do action `\(action.id)` with parameters \(validatedParameters).")
        // Call Action
    }

    // MARK: Resources

    func resource(id: String) -> MeshResource {
        guard let resource = resources.first(where: { $0.id == id }) else {
            fatalError("No resource found with id `\(id)`!")
        }

        return resource
    }

    func syncResources() async throws {
        for resource in resources {
            try await resource.sync()
        }
    }

    func data(id: String) -> StateItem {
        let split = id.components(separatedBy: ".")
        guard split.count == 2 else {
            fatalError("Invalid data id \(id)!")
        }

        return resource(id: split[0]).data(split[1])
    }
}

extension StateItem {
    fileprivate func matchesType(_ type: String) -> Bool {
        switch self {
        case .array:
            return type == "array"
        case .object:
            return type == "object"
        case .bool:
            return type == "bool"
        case .float:
            return type == "float"
        case .string:
            return type == "string"
        case .int:
            return type == "int"
        }
    }
}

/*
 # Actions

 1. YAML Definition
 - potentially associated with a resource
 - has parameters
 - parameters have types
    - Should they have a type? IMO yes - makes client side validation possible, and more readable/understandable YAML for slightly more lines.

 2. Storage in App

 - all actions live in AppState; no per-screen actions (since they shouldn't do anything except modify routing state)
 - action parameter for button; anything else?

 */
