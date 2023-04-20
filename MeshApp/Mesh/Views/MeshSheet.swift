import SwiftUI

struct MeshSheet: View {
    @Binding var screen: MeshScreen?

    var body: some View {
        ZStack(alignment: .bottom) {
            if let screen {
                Color
                    .black
                    .opacity(0.3)
                    .ignoresSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        self.screen = nil
                    }
                screen
                    .render()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                    .background(Color.white)
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: screen)
        .ignoresSafeArea()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorners(radius: radius, corners: corners) )
    }
}

struct RoundedCorners: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
