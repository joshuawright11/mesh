import SwiftUI
import Yams

struct MeshImage: MeshView {
    enum ImageType {
        case symbol(String)
        case url(String)
    }

    static var type: String = "image"

    let type: ImageType
    let resize: ContentMode?

    init(yaml: Node) {
        if let url = yaml["url"]?.string {
            self.type = .url(url)
        } else if let symbol = yaml["symbol"]?.string {
            self.type = .symbol(symbol)
        } else {
            print("[Image] Image had no `url` or `symbol` field.")
            self.type = .symbol("questionmark")
        }

        switch yaml["resize"]?.string {
        case "fit":
            resize = .fit
        case "fill":
            resize = .fill
        case .none:
            resize = nil
        default:
            print("[Image] Unknown resize value `\(yaml["resize"]?.string ?? "N/A")`.")
            resize = nil
        }
    }

    var body: some View {
        ZStack {
            switch type {
            case .symbol(let symbol):
                Image(systemName: symbol)
            case .url(let url):
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .ifLet(resize) {
                                $0
                                    .resizable()
                                    .aspectRatio(contentMode: $1)
                            }
                    case .failure(let error):
                        let _ = print("[Image] Error loading \(url): \(error).")
                        Image(systemName: "questionmark")
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
    }
}
