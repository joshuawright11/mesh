import SwiftUI
import Yams

final class Mesh {
    static let main = Mesh()

    private var _registry: [String: (Node) -> AnyView] = [:]

    func register(_ view: (some MeshView).Type) {
        _registry[view.type] = { AnyView(view.init(yaml: $0)) }
    }

    func renderer(for viewString: String) -> ((Node) -> AnyView)? {
        _registry[viewString]
    }

    private func registerDefaults() {
        register(MeshHStack.self)
        register(MeshVStack.self)
        register(MeshZStack.self)
        register(MeshText.self)
        register(MeshSpacer.self)
        register(MeshButton.self)
        register(MeshTabView.self)
        register(MeshImage.self)
        register(MeshField.self)
        register(MeshList.self)
        register(MeshScroll.self)
    }

    static func renderer(for viewString: String) -> ((Node) -> AnyView)? {
        main.renderer(for: viewString)
    }

    static func setup() {
        main.registerDefaults()
    }
}
