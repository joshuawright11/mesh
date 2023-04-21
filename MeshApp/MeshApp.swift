import SwiftUI

@main
struct MeshApp: App {
    @StateObject var app: AppState
    @State var showPush: Bool = false

    var body: some Scene {
        WindowGroup {
            MeshNavigationStack {
                VStack {
                    List(app.screens) { screen in
                        Button(screen.id) {
                            app.present(id: screen.id, style: .fullscreen)
                        }
                    }
                    .navigationTitle("Screens")
                }
            }
            .environmentObject(app)
        }
    }

    init() {
        // Setup Mesh.
        Mesh.setup()

        // Get YAML.
        let yaml = try! TemplateService().getYAML()!

        // Setup Router.
        let screens = MeshScreen.loadScreens(from: yaml)
        let app = AppState(screens: screens)
        _app = StateObject(wrappedValue: app)
    }
}
