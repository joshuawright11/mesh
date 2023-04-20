import SwiftUI
import Yams

struct MeshTabView: MeshView, Presenter {
    struct TabItem {
        let index: Int
        let screenId: String
        let title: String
        let icon: String
        var path: [MeshScreen] = []
    }

    static let type = "tab"

    @EnvironmentObject var router: Router
    @State var selectedTab: Int

    @State private var modal: MeshScreen?
    @State private var fullscreen: MeshScreen?
    @State private var sheet: MeshScreen?
    @State private var items: [TabItem]

    init(yaml: Node) {
        let screens = yaml["content"]?.sequence ?? []
        let items: [TabItem] = screens.enumerated().compactMap { index, element in
            guard
                let screenId = element["screen"]?.string,
                let title = element["title"]?.string,
                let icon = element["icon"]?.string
            else {
                return nil
            }

            return TabItem(index: index, screenId: screenId, title: title, icon: icon)
        }

        self.selectedTab = 0
        self.items = items
    }

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    router
                        .screen(for: item.screenId)?
                        .render(inNavigation: true, inTab: true, customPath: $items[index].path)
                        .tabItem {
                            Label(item.title, systemImage: item.icon)
                        }
                        .tag(item.index)
                }
            }
            MeshSheet(screen: $sheet)
        }
        .sheet(item: $modal) {
            $0.render(inNavigation: true)
        }
        .fullScreenCover(item: $fullscreen) {
            $0.render(inNavigation: true)
        }
        .onAppear {
            router.pushPresenter(self)
        }
        .onDisappear {
            router.popPresenter()
        }
    }

    func present(screen: MeshScreen, style: PresentationStyle) {
        if sheet != nil {
            sheet = nil
        }

        switch style {
        case .modal:
            self.modal = screen
        case .fullscreen:
            self.fullscreen = screen
        case .push:
            self.items[selectedTab].path.append(screen)
        case .sheet:
            self.sheet = screen
        }
    }
}

/*
 Tab View
 - each element should have it's own navigation view
 - tab should not be wrapped in a navigation view

 - crash when tab in nav and views have nav
 - tab should not be nav!

 - tab should change the top level presenter, as it changes tabs
    - technically the presenter at it's index; in case it's not at index 0
 */
