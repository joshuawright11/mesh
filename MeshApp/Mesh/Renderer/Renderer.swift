import SwiftUI
import Yams

struct Renderer {
    // Kill this maybe? In favor of just the screen.
    @ViewBuilder
    func render(_ screen: MeshScreen, inNavigation: Bool = false) -> some View {
        if inNavigation {
            MeshNavigationStack {
                screen
            }
        } else {
            screen
        }
    }
}

struct MeshNavigationStack<Content: View>: View, Presenter {
    @EnvironmentObject private var router: Router
    @State private var modal: MeshScreen?
    @State private var path: [MeshScreen] = []
    @State private var sheet: MeshScreen?

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                ZStack {
                    content()
                }
                .navigationDestination(for: MeshScreen.self) { screen in
                    Renderer().render(screen)
                }
            }
            MeshSheet(screen: $sheet)
        }
        .sheet(item: $modal) { screen in
            Renderer()
                .render(screen, inNavigation: true)
        }
        .onAppear {
            router.pushModalPresenter(self)
        }
        .onDisappear {
            router.popModalPresenter()
        }
    }

    func present(screen: MeshScreen, style: PresentationStyle) {
        if sheet != nil {
            sheet = nil
        }

        switch style {
        case .modal:
            self.modal = screen
        case .push:
            self.path.append(screen)
        case .sheet:
            self.sheet = screen
        }
    }
}

extension MeshScreen: View {
    var body: some View {
        root
    }
}

extension Node: View {
    public var body: some View {
        guard let dict = mapping else {
            fatalError("Not a Dict!")
        }

        guard let (key, value) = dict.first else {
            fatalError("No Keys!")
        }

        guard
            let string = key.string,
            let render = MeshViewRegistry.main.renderer(for: string)
        else {
            print("[Parsing] Encountered unknown view type `\(key.string ?? "N/A")`, ignoring.")
            return AnyView(EmptyView())
        }

        let general = GeneralProperties(node: value)
        return AnyView(render(value).apply(general))
    }
}
