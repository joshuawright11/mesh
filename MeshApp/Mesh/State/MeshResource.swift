import Foundation
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
    let id: String
    let actions: [String: MeshAction]
    var dataSources: [String: MeshDataSource]

    init(id: String, collections: [String]) {
        self.id = id
        self.actions = [:]
        self.dataSources = collections.map(MeshDataSource.init).keyed(by: \.id)
    }

    // MARK: Data

    func data(_ id: String) -> StateItem {
        guard let source = dataSources[id] else {
            fatalError("[Resource] Unable to find datasource with id \(id)! Available data sources were: \(dataSources.keys).")
        }

        return source.data
    }

    struct DataResponse: Codable {
        let data: [[String: String]]
    }

    @MainActor
    mutating func sync() async throws {
        for id in dataSources.keys {
            let url = URL(string: "http://localhost:3000/v1/resources/\(self.id)/\(id)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let res = try decoder.decode(DataResponse.self, from: data)
            let items: [StateItem] = res.data.map { .object($0.mapValues { .string($0) }) }
            dataSources[id]?.data = .array(items)
            print("[Resource] Finished Syncing \(id).")
        }
    }
}
