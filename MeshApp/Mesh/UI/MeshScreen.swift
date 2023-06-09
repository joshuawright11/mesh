import SwiftUI
import Yams

struct MeshScreen: Identifiable, Hashable {
    let id: String
    let root: Node?

    init?(yaml: Node) {
        guard let dict = yaml.mapping else {
            print("[Parsing] Screen wasn't a dict.")
            return nil
        }

        guard let (key, value) = dict.first else {
            print("[Parsing] Screen had no keys.")
            return nil
        }

        guard let id = key.string else {
            print("[Parsing] Invalid screen id: \(key).")
            return nil
        }

        self.id = id
        self.root = value.sequence?.first
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func loadScreens(from yaml: Node) -> [MeshScreen] {
        guard let sequence = yaml.sequence else {
            print("[Parsing] Top level of YAML must be a sequence to parse screens.")
            return []
        }

        let screens = sequence.compactMap(MeshScreen.init)
        print("[Parsing] Loaded screens: \(screens.map(\.id)).")
        return screens
    }
}

extension MeshScreen {
    @ViewBuilder
    func render(inNavigation: Bool = false, inTab: Bool = false, customPath: Binding<[MeshScreen]>? = nil, newScreen: Bool = false) -> some View {
        root?.render(inNavigation: inNavigation, inTab: inTab, customPath: customPath, newScreen: newScreen)
    }
}

extension Node {
    func render(viewState: [String: StateItem] = [:], inNavigation: Bool = false, inTab: Bool = false, customPath: Binding<[MeshScreen]>? = nil, newScreen: Bool = false) -> some View {
        guard
            let dict = mapping,
            let (key, value) = dict.first,
            let string = key.string
        else {
            return AnyView(EmptyView())
        }

        guard let render = Mesh.renderer(for: string) else {
            print("[Parsing] Encountered unknown view type `\(key.string ?? "N/A")`, ignoring.")
            return AnyView(EmptyView())
        }

        @ViewBuilder
        func _render() -> some View {
            ViewView(state: viewState) {
                let general = GeneralProperties(yaml: value)
                if string == "tab" || !inNavigation {
                    render(value)
                        .apply(general)
                } else {
                    MeshNavigationStack(inTab: inTab, customPath: customPath) {
                        render(value)
                            .apply(general)
                    }
                }
            }
        }

        if newScreen {
            return AnyView(
                ScreenView {
                    _render()
                }
            )
        } else {
            return AnyView(
                _render()
            )
        }
    }
}
