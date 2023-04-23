import Yams

struct MeshDataSource {
    let id: String
    let parameters: [String: String]

    init?(yaml: Node) {
        guard let dict = yaml.mapping else {
            print("[Parsing] Data source wasn't a dict.")
            return nil
        }

        guard let (key, value) = dict.first else {
            print("[Parsing] Data source had no keys.")
            return nil
        }

        guard let id = key.string else {
            print("[Parsing] Invalid data source id: \(key).")
            return nil
        }

        self.id = id

        let parameters = value.mapping ?? [:]
        var parameterDict: [String: String] = [:]
        for (key, value) in parameters {
            guard let key = key.string, let value = value.string else {
                print("[Parsing] Invalid data source parameter!")
                continue
            }

            parameterDict[key] = value
        }

        self.parameters = parameterDict
    }

    static func loadDataSources(from yaml: Node) -> [MeshDataSource] {
        guard let sequence = yaml.sequence else {
            print("[Parsing] Top level of YAML must be a sequence to parse data sources.")
            return []
        }

        let dataSources = sequence.compactMap(MeshDataSource.init)
        print("[Parsing] Loaded data sources: \(dataSources.map(\.id)).")
        return dataSources
    }
}
