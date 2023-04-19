import SwiftUI
import Yams

struct MeshHStack: MeshView {
    static var type: String = "hstack"

    let spacing: CGFloat?
    let alignment: VerticalAlignment
    let content: Node.Sequence

    init(yaml: Node) {
        guard let mapping = yaml.mapping else {
            fatalError("Unable to parse HStack!")
        }

        switch mapping["alignment"]?.string {
        case "top":
            alignment = .top
        case "bottom":
            alignment = .bottom
        case "center":
            alignment = .center
        default:
            alignment = .center
        }

        spacing = (mapping["spacing"]?.float ?? nil).map { $0 }
        content = mapping["content"]?.sequence ?? []
    }

    var body: some View {
        HStack(alignment: alignment, spacing: spacing) {
            ForEach(Array(content.enumerated()), id: \.offset) { _, node in
                node
            }
        }
    }
}
