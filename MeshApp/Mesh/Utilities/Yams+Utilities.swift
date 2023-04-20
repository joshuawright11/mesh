import Foundation
import Yams

extension Node {
    var cgFloat: CGFloat? {
        float.map { CGFloat($0) }
    }
}
