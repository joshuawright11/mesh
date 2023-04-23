import Yams

/*
 Resource
 - represents server side data (todos, users, posts)
 - pull data to show in app
 - data can be queried
 - associated actions (CRUD + custom)
 */

/*
 Case Study - Roam

 Data

 1. User (special case this?)
 2. [Trip] (owned)
 3. [Airport] (shared)
 4. [Flight] (owned)

 Actions

 1. Create Trip
 2. Edit Trip
 3. Delete Trip
 4. Log In
 5. Log Out
 6. [Server] Find Flights

 Actions
 1. Sometimes related to resources - create, update, delete
 2. Sometimes mostly unrelated (search flights)
 3. By forcing them to be on resources, things get odd (i.e. create ACH from Apollo - lots of under the hood steps that result in a new ACH transfer, but very indirectly)
 4. Data Sources can have simple CRUD actions that insert into a database.
 5. Then add global actions that can do anything - including insert into a database.

 */

struct MeshResource {
    struct Item {
        let fields: [String: StateItem]
    }

    let id: String
    let data: [MeshDataSource]
    let actions: [MeshAction]

    init?(yaml: Node) {
        guard let dict = yaml.mapping else {
            print("[Parsing] Resource wasn't a dict.")
            return nil
        }

        guard let (key, value) = dict.first else {
            print("[Parsing] Resource had no keys.")
            return nil
        }

        guard let id = key.string else {
            print("[Parsing] Invalid resource id: \(key).")
            return nil
        }

        self.id = id
        let resourceDict = value.mapping ?? [:]
        let actions = resourceDict["actions"]?.sequence ?? []
        let data = resourceDict["data"]?.sequence ?? []

        self.actions = actions.compactMap(MeshAction.init)
        self.data = data.compactMap(MeshDataSource.init)
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
        print("[Parsing] Loaded resources: \(actions.map(\.id)).")
        return actions
    }
}
