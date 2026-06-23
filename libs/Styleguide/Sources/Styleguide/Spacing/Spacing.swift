import UIKit

public enum Spacing {
    // MARK: - Spacing Scale (8pt grid system)

    private enum Scale: CGFloat, CaseIterable {
        case none = 0
        case xs = 4 // 0.5x
        case sm = 8 // 1x
        case md = 16 // 2x
        case lg = 24 // 3x
        case xl = 32 // 4x
        case xxl = 40 // 5x
        case xxxl = 48 // 6x
        case huge = 64 // 8x
    }

    // MARK: - Semantic Spacing

    public enum Semantic {
        // Component internal spacing
        public static let componentPadding: CGFloat = Scale.md.rawValue
        public static let componentMargin: CGFloat = Scale.sm.rawValue

        // Layout spacing
        public static let sectionSpacing: CGFloat = Scale.lg.rawValue
        public static let itemSpacing: CGFloat = Scale.md.rawValue
        public static let groupSpacing: CGFloat = Scale.sm.rawValue

        // Screen margins
        public static let screenMargin: CGFloat = Scale.md.rawValue
        public static let screenPadding: CGFloat = Scale.lg.rawValue

        // Navigation
        public static let navigationBarHeight: CGFloat = 44
        public static let tabBarHeight: CGFloat = 49
        public static let statusBarHeight: CGFloat = 20

        // Touch targets
        public static let minimumTouchTarget: CGFloat = 44
        public static let buttonHeight: CGFloat = 48
        public static let buttonHeightSmall: CGFloat = 36
        public static let buttonHeightLarge: CGFloat = 56

        // Borders and dividers
        public static let borderWidth: CGFloat = 1
        public static let dividerHeight: CGFloat = 0.5
        public static let separatorHeight: CGFloat = 1

        // Corner radius
        public static let cornerRadiusSmall: CGFloat = 4
        public static let cornerRadiusMedium: CGFloat = 8
        public static let cornerRadiusLarge: CGFloat = 12
        public static let cornerRadiusXLarge: CGFloat = 16
        public static let cornerRadiusXXLarge: CGFloat = 24
        public static let cornerRadiusXXXLarge: CGFloat = 30

        // Shadows
        public static let shadowRadius: CGFloat = 4
        public static let shadowOffset = CGSize(width: 0, height: 2)
        public static let shadowOpacity: Float = 0.1

        // Soft elevation — used by the floating-card surfaces (no border, gentle lift).
        // Deliberately larger/softer and lower-opacity than the hard `shadow*` above.
        public static let shadowSoftRadius: CGFloat = 24
        public static let shadowSoftOffset = CGSize(width: 0, height: 14)
        public static let shadowSoftOpacity: Float = 0.06

        public static let shadowFloatingRadius: CGFloat = 32
        public static let shadowFloatingOffset = CGSize(width: 0, height: 16)
        public static let shadowFloatingOpacity: Float = 0.08
    }

    // MARK: - Layout Constants

    public enum Layout {
        // Grid system
        public static let gridColumns: Int = 12
        public static let gridGutter: CGFloat = Scale.md.rawValue

        // Content width constraints
        public static let maxContentWidth: CGFloat = 600
        public static let maxFormWidth: CGFloat = 400

        // List item heights
        public static let listItemHeight: CGFloat = 56
        public static let listItemHeightSmall: CGFloat = 44
        public static let listItemHeightLarge: CGFloat = 72

        // Card dimensions
        public static let cardMinHeight: CGFloat = 100
        public static let cardMaxHeight: CGFloat = 300
    }

    public static func safeAreaInsets(for view: UIView) -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return UIEdgeInsets.zero
        }
    }
}
