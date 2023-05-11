import SwiftUI
import Yams

struct MeshText: MeshView {
    enum Value {
        case constant(String)
        case state(String)
    }

    static var type: String = "text"

    let text: Value
    let fontSize: Int

    @EnvironmentObject var screen: ScreenState
    @EnvironmentObject var view: ViewState

    init(yaml: Node) {
        guard let mapping = yaml.mapping else {
            fatalError("Unable to parse HStack!")
        }

        let text = mapping["text"]?.string ?? ""
        if text.first == "{" && text.last == "}" {
            self.text = .state(String(text.dropFirst().dropLast()))
        } else {
            self.text = .constant(text)
        }

        fontSize = mapping["fontSize"]?.int ?? 17
    }

    var body: some View {
        Text(textString)
            .font(.system(size: CGFloat(fontSize)))
    }

    private var textString: String {
        switch text {
        case .constant(let value):
            return value
        case .state(let key):
            let storage = screen.storage.merging(view.storage, uniquingKeysWith: { (_, new) in new })
            switch storage[key] {
            case .some(let state):
                return state.description
            case .none:
                return "{\(key) not found}"
            }
        }
    }
}
