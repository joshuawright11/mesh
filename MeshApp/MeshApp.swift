import SwiftUI

@main
struct MeshApp: App {
    @StateObject var app = AppState()
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
            .onAppear {
                Mesh.setup()
                Task {
                    try await app.syncResources()
                }
                Task {
                    try await app.syncScreens()
                }
            }
        }
    }
}
