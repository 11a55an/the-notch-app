import SwiftUI

struct NotchShape: Shape, InsettableShape {
    var bottomCornerRadius: CGFloat
    var topCornerRadius: CGFloat = 0
    var topEarWidth: CGFloat = 0
    var insetAmount: CGFloat = 0

    var animatableData: CGFloat {
        get { bottomCornerRadius }
        set { bottomCornerRadius = newValue }
    }

    func inset(by amount: CGFloat) -> NotchShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        var path = Path()
        let botR = min(max(bottomCornerRadius - insetAmount, 0), rect.width / 2, rect.height / 2)
        let topR = min(max(topCornerRadius - insetAmount, 0), rect.height / 2)
        let ear = min(max(topEarWidth, 0), rect.width / 2 - botR)
        let bodyMinX = rect.minX + ear
        let bodyMaxX = rect.maxX - ear

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

        if topR > 0 || ear > 0 {
            path.addQuadCurve(
                to: CGPoint(x: bodyMaxX, y: rect.minY + topR),
                control: CGPoint(x: bodyMaxX, y: rect.minY)
            )
        }

        path.addLine(to: CGPoint(x: bodyMaxX, y: rect.maxY - botR))
        if botR > 0 {
            path.addQuadCurve(
                to: CGPoint(x: bodyMaxX - botR, y: rect.maxY),
                control: CGPoint(x: bodyMaxX, y: rect.maxY)
            )
        }
        path.addLine(to: CGPoint(x: bodyMinX + botR, y: rect.maxY))
        if botR > 0 {
            path.addQuadCurve(
                to: CGPoint(x: bodyMinX, y: rect.maxY - botR),
                control: CGPoint(x: bodyMinX, y: rect.maxY)
            )
        }
        path.addLine(to: CGPoint(x: bodyMinX, y: rect.minY + topR))
        if topR > 0 || ear > 0 {
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.minY),
                control: CGPoint(x: bodyMinX, y: rect.minY)
            )
        }
        path.closeSubpath()
        return path
    }
}
