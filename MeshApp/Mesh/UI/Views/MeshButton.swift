import SwiftUI
import Yams

struct MeshButton: MeshView {
    static var type: String = "button"

    enum Action {
        case present(String, PresentationStyle)
        case dismiss(Bool)
        case openURL(String)
        case action(String)
    }

    let text: String
    let action: Action?
    let parameters: [String: String]

    @EnvironmentObject var app: AppState
    @EnvironmentObject var screen: ScreenState

    init(yaml: Node) {
        guard let mapping = yaml.mapping else {
            fatalError("Unable to parse HStack!")
        }

        text = mapping["text"]?.string ?? "Text"

        let actionSequence = mapping["action"]?.sequence
        switch actionSequence?.count {
        case .none:
            action = nil
        case 3 where actionSequence?[0].string == "present":
            let style: PresentationStyle = {
                switch actionSequence?[1].string {
                case "modal":
                    return .modal
                case "push":
                    return .push
                case "sheet":
                    return .sheet
                default:
                    print("[Router] Unknown presentaiton style \(actionSequence?[1].string ?? "N/A").")
                    return .modal
                }
            }()
            action = .present(actionSequence?[2].string ?? "", style)
        case 2 where actionSequence?[0].string == "action":
            action = .action(actionSequence?[1].string ?? "")
        case 2 where actionSequence?[0].string == "open":
            action = .openURL(actionSequence?[1].string ?? "")
        case 1 where actionSequence?[0].string == "dismiss":
            action = .dismiss(false)
        case 2 where actionSequence?[0].string == "dismiss" && actionSequence?[1].string == "modal":
            action = .dismiss(true)
        default:
            print("[Parsing] Unknown button action length \(actionSequence?.count ?? 0).")
            action = nil
        }

        let parameters = yaml["parameters"]?.mapping ?? [:]
        var parameterDict: [String: String] = [:]
        for (key, value) in parameters {
            guard let key = key.string, let value = value.string else {
                print("[Parsing] Unable to parse button parameter!")
                continue
            }

            parameterDict[key] = value
        }

        self.parameters = parameterDict
    }

    var body: some View {
        Button(text, action: tapped)
    }

    func tapped() {
        switch action {
        case .present(let screenId, let style):
            app.present(id: screenId, style: style)
        case .action(let actionId):
            let _parameters = parameters
                .compactMapValues { value -> StateItem? in
                    let trimmed = String(value.dropFirst().dropLast())
                    guard let value = screen.storage[trimmed] else {
                        print("[Action] No value for parameter `\(value)` in screen state.")
                        return nil
                    }

                    return value
                }

            app.action(actionId, parameters: _parameters)
        case .openURL(let urlString):
            app.openURL(URL(string: urlString)!)
        case .dismiss(let modal):
            app.dismiss(modal: modal)
        case .none:
            break
        }
    }
}
