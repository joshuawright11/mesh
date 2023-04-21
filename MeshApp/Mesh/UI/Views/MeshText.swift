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
            switch screen.storage[key] {
            case .string(let value):
                return value
            default:
                return "Nothing :("
            }
        }
    }
}
