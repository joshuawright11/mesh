import SwiftUI
import Yams

struct MeshScreen: Identifiable, Hashable {
    let id: String
    let root: Node?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

protocol MeshView: View {
    static var type: String { get }
    init(yaml: Node)
}

struct GeneralProperties {
    struct Shadow {
        let color: String
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    enum Fill {
        case x, y, xy
    }

    let padding: EdgeInsets?
    let cornerRadius: CGFloat?
    let background: String?
    let shadow: Shadow?
    let fill: Fill?
    let title: String?

    init(node: Node) {
        let paddingSequence = node["padding"]?.sequence ?? []
        switch paddingSequence.count {
        case 0:
            padding = nil
        case 1:
            let value: Double = paddingSequence[0].float ?? 0
            padding = EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
        case 2:
            let tb: Double = paddingSequence[0].float ?? 0
            let lt: Double = paddingSequence[1].float ?? 0
            padding = EdgeInsets(top: tb, leading: lt, bottom: tb, trailing: lt)
        case 4:
            padding = EdgeInsets(
                top: paddingSequence[0].float ?? 0,
                leading: paddingSequence[1].float ?? 0,
                bottom: paddingSequence[2].float ?? 0,
                trailing: paddingSequence[3].float ?? 0
            )
        default:
            print("[Parsing] Unknown padding length \(paddingSequence.count).")
            padding = nil
        }

        cornerRadius = node["cornerRadius"]?.cgFloat
        background = node["background"]?.string

        let shadowSequence = node["shadow"]?.sequence ?? []
        switch shadowSequence.count {
        case 0:
            shadow = nil
        case 2:
            shadow = Shadow(
                color: shadowSequence[0].string ?? "",
                radius: shadowSequence[1].cgFloat ?? 0,
                x: 0,
                y: 0)
        case 4:
            shadow = Shadow(
                color: shadowSequence[0].string ?? "",
                radius: shadowSequence[1].cgFloat ?? 0,
                x: shadowSequence[2].cgFloat ?? 0,
                y: shadowSequence[3].cgFloat ?? 0)
        default:
            print("[Parsing] Unknown shadow length \(paddingSequence.count).")
            shadow = nil
        }

        if let fillSequence = node["fill"]?.sequence {
            let strings = fillSequence.map(\.string)
            if strings.contains("x") && strings.contains("y") {
                fill = .xy
            } else if strings.contains("x") {
                fill = .x
            } else if strings.contains("y") {
                fill = .y
            } else {
                fill = nil
            }
        } else {
            fill = nil
        }

        title = node["title"]?.string
    }
}

extension Node {
    var cgFloat: CGFloat? {
        float.map { CGFloat($0) }
    }
}

extension View {
    func apply(_ properties: GeneralProperties) -> some View {
        self
            .ifLet(properties.fill) { view, fill in
                let fillX = fill == .x || fill == .xy
                let fillY = fill == .y || fill == .xy
                return view.frame(maxWidth: fillX ? .infinity : nil, maxHeight: fillY ? .infinity : nil)
            }
            .ifLet(properties.padding) { $0.padding($1) }
            .ifLet(properties.background) { $0.background(Color(hex: $1)) }
            .ifLet(properties.shadow) { $0.shadow(color: Color(hex: $1.color), radius: $1.radius, x: $1.x, y: $1.y) }
            .ifLet(properties.cornerRadius) { $0.cornerRadius($1) }
            .ifLet(properties.title) { $0.navigationTitle($1) }
    }

    @ViewBuilder
    private func ifLet<T>(_ value: T?, modifier: (Self, T) -> some View) -> some View {
        if let value {
            modifier(self, value)
        } else {
            self
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
