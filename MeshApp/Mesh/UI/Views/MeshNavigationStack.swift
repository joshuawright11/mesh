import SwiftUI

struct MeshNavigationStack<Content: View>: View, Presenter {
    @EnvironmentObject private var router: AppState
    @Environment(\.openURL) var openURLAction
    @Environment(\.dismiss) var dismiss
    @State private var modal: MeshScreen?
    @State private var fullscreen: MeshScreen?
    @State private var path: [MeshScreen] = []
    @State private var sheet: MeshScreen?
    private var customPath: Binding<[MeshScreen]>?

    let inTab: Bool
    let content: () -> Content

    init(inTab: Bool = false, customPath: Binding<[MeshScreen]>? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.inTab = inTab
        self.customPath = customPath
        self.content = content
    }

    var body: some View {
        ZStack {
            NavigationStack(path: customPath ?? $path) {
                ZStack {
                    content()
                }
                .navigationDestination(for: MeshScreen.self) {
                    $0.render(newScreen: true)
                }
            }
            MeshSheet(screen: $sheet)
        }
        .sheet(item: $modal) {
            $0.render(inNavigation: true, newScreen: true)
        }
        .fullScreenCover(item: $fullscreen) {
            $0.render(inNavigation: true, newScreen: true)
                .onTapGesture(count: 5) {
                    fullscreen = nil
                }
        }
        .onAppear {
            if !inTab { router.pushPresenter(self) }
        }
        .onDisappear {
            if !inTab { router.popPresenter() }
        }
    }

    func present(screen: MeshScreen, style: PresentationStyle) {
        if sheet != nil {
            sheet = nil
        }

        switch style {
        case .modal:
            modal = screen
        case .fullscreen:
            fullscreen = screen
        case .push:
            if let customPath {
                customPath.wrappedValue.append(screen)
            } else {
                path.append(screen)
            }
        case .sheet:
            sheet = screen
        }
    }

    func openURL(_ url: URL) {
        openURLAction(url)
    }

    func dismiss(modal: Bool) {
        guard !modal else {
            dismiss()
            return
        }

        if sheet != nil {
            sheet = nil
        } else if path.count > 0 {
            _ = path.popLast()
        } else {
            dismiss()
        }
    }
}
