import SwiftUI
import Yams

struct MeshText: MeshView {
    static var type: String = "text"

    let text: String
    let fontSize: Int

    init(yaml: Node) {
        guard let mapping = yaml.mapping else {
            fatalError("Unable to parse HStack!")
        }

        text = mapping["text"]?.string ?? "Text"
        fontSize = mapping["fontSize"]?.int ?? 17
    }

    var body: some View {
        Text(text)
            .font(.system(size: CGFloat(fontSize)))
    }
}
