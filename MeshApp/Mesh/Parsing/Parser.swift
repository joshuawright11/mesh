import UIKit
import SwiftUI
import Yams

/*
 Template Structure
 DICT OF SCREENS:
    ARRAY OF VIEWS:
        DICT OF PROPERTIES:
 */

struct TemplateParser {
    func parse() -> [MeshScreen] {
        // Get YAML nodes
        let url = Bundle.main.url(forResource: "Data", withExtension: ".yaml")!
        let string = try! String(contentsOf: url)
        let node = try! Yams.compose(yaml: string)

        // Parse into views, ignoring missing pieces
        let sequence = node?.sequence ?? []
        let screens = sequence.compactMap { $0.decodeMeshScreen() }
        print("[Parsing] Loaded screens: \(screens.map(\.id)).")
        return screens
    }
}

extension Node {
    fileprivate func decodeMeshScreen() -> MeshScreen? {
        guard let dict = mapping else {
            fatalError("Not a Dict!")
        }

        guard let (key, value) = dict.first else {
            fatalError("No Keys!")
        }

        guard let id = key.string else {
            print("Invalid screen id: \(key).")
            return nil
        }

        let sequence = value.sequence ?? []
        return MeshScreen(id: id, root: sequence.first)
    }
}



// MARK: Types

/*
 Backend = abstraction for general resources
 Template = abstraction for views bound to resources
    - Views
    - Scenes
 Generator = turns template into platform code
    - Router
    - Backend Calls
    - View
 */

/*
 DONE Pass 1:
 1. HStack
 2. VStack
 3. ZStack
 4. Text

 Pass 2:
 1. Button
 2. Field

 Pass 3:
 1. Static List
 2. Dynamic List
 */
