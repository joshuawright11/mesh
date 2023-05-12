import SwiftUI
import Yams

/// There are one of these per Mesh App. Use this to keep track of global state
/// and route between screens.
final class AppState: ObservableObject {
    struct ResourcesResponse: Codable {
        struct Resource: Codable {
            let id: String
            let collections: [String]
        }

        let resources: [Resource]
    }

    /// Local
    @Published var screens: [MeshScreen] = []
    @Published var storage: [String: StateItem] = [:]

    // Remote
    @Published var resources: [MeshResource] = []

    private var presenters: [Presenter] = []

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

    @MainActor
    func action(_ id: String, parameters: [String: StateItem]) async throws {
        print("[Actions] Do action `\(id)` with parameters \(parameters).")
        let url = URL(string: "http://localhost:3000/v1/actions/\(id)")!
        let encoded = try JSONEncoder().encode(parameters)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        _ = try await URLSession.shared.upload(for: req, from: encoded)
    }

    // MARK: Resources

    func resource(id: String) -> MeshResource {
        guard let resource = resources.first(where: { $0.id == id }) else {
            fatalError("No resource found with id `\(id)`!")
        }

        return resource
    }

    @MainActor
    func syncResources() async throws {
        let url = URL(string: "http://localhost:3000/v1/resources")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(ResourcesResponse.self, from: data)
        self.resources = response.resources.map { MeshResource(id: $0.id, collections: $0.collections) }
        for i in 0..<resources.count {
            try await resources[i].sync()
        }
    }

    @MainActor
    func syncScreens() async throws {
        let url = URL(string: "http://localhost:3000/v1/views")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let string = String(data: data, encoding: .utf8)!
        let viewsYaml = try Yams.compose(yaml: string)!
        let screens = MeshScreen.loadScreens(from: viewsYaml)
        self.screens = screens
        print("[Resource] Finished Syncing Views.")
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
