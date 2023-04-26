import SwiftUI

enum StateItem:
    ExpressibleByBooleanLiteral,
    ExpressibleByStringLiteral,
    ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral
{
    case bool(Bool)
    case int(Int)
    case string(String)
    case float(Double)
    case array([StateItem])
    case object([String: StateItem])

    init(floatLiteral value: Double) {
        self = .float(value)
    }

    init(stringLiteral value: String) {
        self = .string(value)
    }

    init(booleanLiteral value: Bool) {
        self = .bool(value)
    }

    init(integerLiteral value: Int) {
        self = .int(value)
    }

    init(arrayLiteral elements: StateItem...) {
        self = .array(elements)
    }

    init(dictionaryLiteral elements: (String, StateItem)...) {
        self = .object(Dictionary(uniqueKeysWithValues: elements))
    }
}
