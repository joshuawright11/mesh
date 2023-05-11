import SwiftUI
import Yams

struct MeshScroll: MeshView {
    static var type: String = "scroll"

    let axis: Axis.Set
    let showsIndicators: Bool
    let content: Node.Sequence

    init(yaml: Node) {
        guard let mapping = yaml.mapping else {
            fatalError("Unable to parse VStack!")
        }

        switch mapping["axis"]?.string {
        case "vertical", .none:
            axis = .vertical
        case "horizontal":
            axis = .horizontal
        default:
            print("Unknown MeshScroll axis \(mapping["axis"]?.string ?? "N/A")")
            axis = .vertical
        }

        showsIndicators = mapping["indicators"]?.bool ?? true
        content = mapping["content"]?.sequence ?? []
    }

    var body: some View {
        ScrollView(axis, showsIndicators: showsIndicators) {
            ForEach(Array(content.enumerated()), id: \.offset) { _, node in
                node.render()
            }
        }
    }
}
