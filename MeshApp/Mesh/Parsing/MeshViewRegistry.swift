import SwiftUI
import Yams

final class MeshViewRegistry {
    static let main = MeshViewRegistry()

    private var _registry: [String: (Node) -> AnyView] = [:]

    func register(_ view: (some MeshView).Type) {
        _registry[view.type] = { AnyView(view.init(yaml: $0)) }
    }

    func renderer(for typeString: String) -> ((Node) -> AnyView)? {
        _registry[typeString]
    }

    func registerDefaults() {
        register(MeshHStack.self)
        register(MeshVStack.self)
        register(MeshZStack.self)
        register(MeshText.self)
        register(MeshSpacer.self)
        register(MeshButton.self)
    }
}
