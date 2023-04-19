import SwiftUI
import Yams

struct MeshZStack: MeshView {
    static var type: String = "zstack"

    let alignment: Alignment
    let content: Node.Sequence

    init(yaml: Node) {
        guard let mapping = yaml.mapping else {
            fatalError("Unable to parse VStack!")
        }

        switch mapping["alignment"]?.string {
        case "center", .none:
            alignment = .center
        case "bottom":
            alignment = .bottom
        case "bottomLeading":
            alignment = .bottomLeading
        case "bottomTrailing":
            alignment = .bottomTrailing
        case "top":
            alignment = .top
        case "topLeading":
            alignment = .topLeading
        case "topTrailing":
            alignment = .topTrailing
        case "trailing":
            alignment = .trailing
        case "leading":
            alignment = .leading
        default:
            alignment = .center
        }

        content = mapping["content"]?.sequence ?? []
    }

    var body: some View {
        ZStack(alignment: alignment) {
            ForEach(Array(content.enumerated()), id: \.offset) { _, node in
                node
            }
        }
    }
}
