import SwiftUI

/// There are one of these per Mesh Screen.
final class ScreenState: ObservableObject {
    @Published var storage: [String: StateItem] = [:]
}
