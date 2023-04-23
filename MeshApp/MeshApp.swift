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
        let service = TemplateService()
        let viewsYAML = try! service.getViewsYAML()!
        let actionsYAML = try! service.getActionsYAML()!
        let resourcesYAML = try! service.getResourcesYAML()!

        // Setup Router.
        let screens = MeshScreen.loadScreens(from: viewsYAML)
        let actions = MeshAction.loadActions(from: actionsYAML)
        let resources = MeshResource.loadResources(from: resourcesYAML)
        let app = AppState(screens: screens, actions: actions, resources: resources)
        _app = StateObject(wrappedValue: app)
    }
}
