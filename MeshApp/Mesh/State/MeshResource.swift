import Yams

/*
 Resource
 - represents server side data (todos, users, posts)
 - pull data to show in app
 - data can be queried
 - associated actions (CRUD + custom)
 */

struct MeshResource {
    struct Item {
        let fields: [String: StateItem]
    }

    let id: String

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

    func data(_ id: String) -> [Item] {
        []
    }

    func action(_ id: String, parameters: [String: StateItem]) {
        print("[Actions] Do action `\(id)` with parameters \(parameters).")
    }

    static func loadResources(from yaml: Node) -> [MeshResource] {
        guard let sequence = yaml.sequence else {
            print("[Parsing] Top level of YAML must be a sequence to parse actions.")
            return []
        }

        let actions = sequence.compactMap(MeshResource.init)
        print("[Parsing] Loaded actions: \(actions.map(\.id)).")
        return actions
    }
}
