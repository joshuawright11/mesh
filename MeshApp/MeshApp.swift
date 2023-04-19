import SwiftUI

@main
struct MeshApp: App {

    @StateObject var router: Router
    @State var showPush: Bool = false

    var body: some Scene {
        WindowGroup {
            MeshNavigationStack {
                VStack {
                    Button("Sheet") {
                        router.present(id: "View 2", style: .sheet)
                    }
                    List(router.screens) { screen in
                        Button(screen.id) {
                            router.present(id: screen.id)
                        }
                    }
                    .navigationTitle("Screens")
                }
            }
            .environmentObject(router)
        }
    }

    init() {
        // Register screens.
        MeshViewRegistry.main.registerDefaults()

        // Parse YAML.
        let screens = TemplateParser().parse()

        // Setup the router.
        let router = Router(screens: screens)
        _router = StateObject(wrappedValue: router)
    }
}
