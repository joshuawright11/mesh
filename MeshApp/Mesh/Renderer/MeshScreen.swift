import SwiftUI
import Yams

struct MeshScreen: Identifiable, Hashable {
    let id: String
    let root: Node?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension MeshScreen {
    @ViewBuilder
    func render(inNavigation: Bool = false, inTab: Bool = false, customPath: Binding<[MeshScreen]>? = nil) -> some View {
        root?.render(inNavigation: inNavigation, inTab: inTab, customPath: customPath)
    }
}

extension Node {
    func render(inNavigation: Bool = false, inTab: Bool = false, customPath: Binding<[MeshScreen]>? = nil) -> some View {
        guard
            let dict = mapping,
            let (key, value) = dict.first,
            let string = key.string
        else {
            return AnyView(EmptyView())
        }

        guard let render = MeshViewRegistry.main.renderer(for: string) else {
            print("[Parsing] Encountered unknown view type `\(key.string ?? "N/A")`, ignoring.")
            return AnyView(EmptyView())
        }

        if string == "tab" || !inNavigation {
            let general = GeneralProperties(node: value)
            return AnyView(render(value).apply(general))
        } else {
            let general = GeneralProperties(node: value)
            return AnyView(
                MeshNavigationStack(inTab: inTab, customPath: customPath) {
                    render(value)
                        .apply(general)
                }
            )
        }
    }
}
