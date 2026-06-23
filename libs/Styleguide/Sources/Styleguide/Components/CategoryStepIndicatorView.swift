import SwiftUI

public struct CategoryStepIndicatorView: View {
    let count: Int
    let currentIndex: Int
    let completedIndices: Set<Int>

    public init(count: Int, currentIndex: Int, completedIndices: Set<Int>) {
        self.count = count
        self.currentIndex = currentIndex
        self.completedIndices = completedIndices
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0 ..< count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(segmentColor(for: index))
                    .frame(height: 4)
            }
        }
    }

    private func segmentColor(for index: Int) -> Color {
        if completedIndices.contains(index) {
            return SemanticColor.Colors.primary.swiftUIColor
        } else if index == currentIndex {
            return SemanticColor.Colors.primary.swiftUIColor.opacity(0.5)
        } else {
            return SemanticColor.Colors.borderSecondary.swiftUIColor
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        CategoryStepIndicatorView(count: 5, currentIndex: 2, completedIndices: [0, 1])
        CategoryStepIndicatorView(count: 3, currentIndex: 0, completedIndices: [])
        CategoryStepIndicatorView(count: 4, currentIndex: 3, completedIndices: [0, 1, 2])
    }
    .padding()
}
#endif
