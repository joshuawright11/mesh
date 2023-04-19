import SwiftUI
import Yams

struct MeshVStack: MeshView {
    static var type: String = "vstack"

    let spacing: CGFloat?
    let alignment: HorizontalAlignment
    let content: Node.Sequence

    init(yaml: Node) {
        guard let mapping = yaml.mapping else {
            fatalError("Unable to parse VStack!")
        }

        switch mapping["alignment"]?.string {
        case "center", .none:
            alignment = .center
        case "leading":
            alignment = .leading
        case "trailing":
            alignment = .trailing
        default:
            alignment = .center
        }

        spacing = (mapping["spacing"]?.float ?? nil).map { $0 }
        content = mapping["content"]?.sequence ?? []
    }

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(Array(content.enumerated()), id: \.offset) { _, node in
                node
            }
        }
    }
}
