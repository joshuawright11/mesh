import UIKit
import SwiftUI
import Yams

/*
 Template Structure
 DICT OF SCREENS:
    ARRAY OF VIEWS:
        DICT OF PROPERTIES:
 */

struct TemplateService {
    func getYAML() throws -> Node? {
        guard let url = Bundle.main.url(forResource: "Data", withExtension: ".yaml") else {
            return nil
        }

        let string = try String(contentsOf: url)
        return try Yams.compose(yaml: string)
    }
}
