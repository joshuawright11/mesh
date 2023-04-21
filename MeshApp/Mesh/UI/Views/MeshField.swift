import SwiftUI
import Yams

struct MeshField: MeshView {
    static var type: String = "field"

    let id: String
    let placeholder: String

    @State var text: String
    @EnvironmentObject var state: ScreenState

    init(yaml: Node) {
        id = yaml["id"]?.string ?? UUID().uuidString
        placeholder = yaml["placeholder"]?.string ?? ""
        text = yaml["text"]?.string ?? ""
    }

    var body: some View {
        TextField(placeholder, text: $text)
            .background(Color.pink)
            .onAppear {
                state.storage[id] = .string(text)
            }
            .onChange(of: text) {
                state.storage[id] = .string($0)
            }
    }
}
