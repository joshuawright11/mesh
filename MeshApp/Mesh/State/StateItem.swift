import SwiftUI

enum StateItem {
    case bool(Bool)
    case int(Int)
    case string(String)
    case float(Double)
    case array([StateItem])
    case object([String: StateItem])
}
