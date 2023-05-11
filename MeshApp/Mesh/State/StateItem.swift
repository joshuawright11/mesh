import SwiftUI

enum StateItem:
    ExpressibleByBooleanLiteral,
    ExpressibleByStringLiteral,
    ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral,
    CustomStringConvertible
{
    case bool(Bool)
    case int(Int)
    case string(String)
    case float(Double)
    case array([StateItem])
    case object([String: StateItem])

    var description: String {
        switch self {
        case .bool(let value):
            return "\(value)"
        case .int(let value):
            return "\(value)"
        case .string(let value):
            return value
        case .float(let value):
            return "\(value)"
        case .array(let value):
            return "\(value)"
        case .object(let value):
            return "\(value)"
        }
    }

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
