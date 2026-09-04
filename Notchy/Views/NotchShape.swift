import SwiftUI

struct NotchShape: Shape {
    var bottomCornerRadius: CGFloat
    var topCornerRadius: CGFloat = 0

    var animatableData: CGFloat {
        get { bottomCornerRadius }
        set { bottomCornerRadius = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topR = min(topCornerRadius, rect.width / 2, rect.height / 2)
        let botR = min(bottomCornerRadius, rect.width / 2, rect.height / 2)

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topR, y: rect.minY))
        if topR > 0 {
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY + topR),
                control: CGPoint(x: rect.maxX, y: rect.minY)
            )
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - botR))
        if botR > 0 {
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - botR, y: rect.maxY),
                control: CGPoint(x: rect.maxX, y: rect.maxY)
            )
        }
        path.addLine(to: CGPoint(x: rect.minX + botR, y: rect.maxY))
        if botR > 0 {
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.maxY - botR),
                control: CGPoint(x: rect.minX, y: rect.maxY)
            )
        }
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topR))
        if topR > 0 {
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + topR, y: rect.minY),
                control: CGPoint(x: rect.minX, y: rect.minY)
            )
        }
        path.closeSubpath()
        return path
    }
}
