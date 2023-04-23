import Yams

struct MeshAction: Identifiable, Hashable {
    let id: String
    let parameters: [String: String]

    init?(yaml: Node) {
        guard let dict = yaml.mapping else {
            print("[Parsing] Action wasn't a dict.")
            return nil
        }

        guard let (key, value) = dict.first else {
            print("[Parsing] Action had no keys.")
            return nil
        }

        guard let id = key.string else {
            print("[Parsing] Invalid action id: \(key).")
            return nil
        }

        self.id = id

        let parameters = value.mapping ?? [:]
        var parameterDict: [String: String] = [:]
        for (key, value) in parameters {
            guard let key = key.string, let value = value.string else {
                print("[Parsing] Invalid action parameter!")
                continue
            }

            parameterDict[key] = value
        }

        self.parameters = parameterDict
    }

    static func loadActions(from yaml: Node) -> [MeshAction] {
        guard let sequence = yaml.sequence else {
            print("[Parsing] Top level of YAML must be a sequence to parse actions.")
            return []
        }

        let actions = sequence.compactMap(MeshAction.init)
        print("[Parsing] Loaded actions: \(actions.map(\.id)).")
        return actions
    }
}
