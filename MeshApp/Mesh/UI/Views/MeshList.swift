import SwiftUI
import Yams

/*
 List
 - data source (hook up to data array)
 - items (N views)
 */

struct MeshList: MeshView {
    static var type: String = "list"

    @EnvironmentObject var screen: ScreenState
    @EnvironmentObject var app: AppState

    let data: String
    let item: Node

    init(yaml: Node) {
        guard let mapping = yaml.mapping else {
            fatalError("Unable to parse List!")
        }

        guard let item = mapping["item"] else {
            fatalError("Missing item in list!")
        }

        self.data = mapping["data"]?.string ?? ""
        self.item = item
    }

    var body: some View {
        List(Array(_data.enumerated()), id: \.offset) { index, value in
            if case .object(let dict) = value {
                item.render(viewState: dict)
            }
        }
    }

    private var _data: [StateItem] {
        switch app.data(id: data) {
        case .array(let array):
            return array
        default:
            return []
        }
    }
}
