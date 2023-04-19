import SwiftUI
import Yams

struct MeshSpacer: MeshView {
    static var type: String = "spacer"

    init(yaml: Node) {
    }

    var body: some View {
        Spacer()
    }
}
