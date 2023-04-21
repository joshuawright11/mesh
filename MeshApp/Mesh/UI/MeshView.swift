import SwiftUI
import Yams

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

    init(yaml: Node) {
        let paddingSequence = yaml["padding"]?.sequence ?? []
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

        cornerRadius = yaml["cornerRadius"]?.cgFloat
        background = yaml["background"]?.string

        let shadowSequence = yaml["shadow"]?.sequence ?? []
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

        switch yaml["fill"]?.string {
        case "x":
            fill = .x
        case "y":
            fill = .y
        case "xy":
            fill = .xy
        case .none:
            fill = nil
        default:
            print("[Parsing] Unknown fill value \(yaml["fill"]?.string ?? "N/A").")
            fill = nil
        }

        title = yaml["title"]?.string
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
}
