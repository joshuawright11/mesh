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
    func getViewsYAML() throws -> Node? {
        guard let url = Bundle.main.url(forResource: "Views", withExtension: ".yaml") else {
            return nil
        }

        let string = try String(contentsOf: url)
        return try Yams.compose(yaml: string)
    }

    func getActionsYAML() throws -> Node? {
        guard let url = Bundle.main.url(forResource: "Actions", withExtension: ".yaml") else {
            return nil
        }

        let string = try String(contentsOf: url)
        return try Yams.compose(yaml: string)
    }

    func getResourcesYAML() throws -> Node? {
        guard let url = Bundle.main.url(forResource: "Resources", withExtension: ".yaml") else {
            return nil
        }

        let string = try String(contentsOf: url)
        return try Yams.compose(yaml: string)
    }
}
