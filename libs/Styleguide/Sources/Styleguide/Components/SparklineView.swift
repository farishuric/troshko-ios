import SwiftUI

/// Minimal pink sparkline: a polyline with rounded caps and an optional end dot.
/// No grid, no axes. Values are plotted in order and self-normalized to the frame.
public struct SparklineView: View {
    private let values: [Double]
    private let showsEndDot: Bool
    private let lineWidth: CGFloat

    public init(values: [Double], showsEndDot: Bool = true, lineWidth: CGFloat = 2.5) {
        self.values = values
        self.showsEndDot = showsEndDot
        self.lineWidth = lineWidth
    }

    public var body: some View {
        GeometryReader { geo in
            let points = normalizedPoints(in: geo.size)
            ZStack {
                linePath(points)
                    .stroke(
                        SemanticColor.Colors.heartRate.swiftUIColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                    )
                if showsEndDot, let last = points.last {
                    Circle()
                        .fill(SemanticColor.Colors.heartRate.swiftUIColor)
                        .frame(width: lineWidth * 2.4, height: lineWidth * 2.4)
                        .position(last)
                }
            }
        }
    }

    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard values.count > 1 else { return [] }
        let minV = values.min() ?? 0
        let maxV = values.max() ?? 1
        let range = max(maxV - minV, 0.0001)
        let stepX = size.width / CGFloat(values.count - 1)
        let inset = lineWidth * 1.5
        let usableH = max(size.height - inset * 2, 1)
        return values.enumerated().map { index, value in
            let x = CGFloat(index) * stepX
            let norm = (value - minV) / range
            let y = inset + (1 - CGFloat(norm)) * usableH
            return CGPoint(x: x, y: y)
        }
    }

    private func linePath(_ points: [CGPoint]) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for point in points.dropFirst() { path.addLine(to: point) }
        }
    }
}

#Preview {
    SparklineView(values: [60, 64, 61, 72, 66, 78, 70, 74, 69, 73])
        .frame(width: 160, height: 48)
        .padding(40)
}
