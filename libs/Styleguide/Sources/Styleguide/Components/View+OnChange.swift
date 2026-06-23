import SwiftUI

extension View {
    /// Drop-in replacement for the deprecated `onChange(of:perform:)`.
    /// Routes to the two-parameter closure on iOS 17+; falls back to the old
    /// API on iOS 15–16 where it is not deprecated.
    @ViewBuilder
    public func onValueChange<T: Equatable>(
        of value: T,
        perform action: @escaping (T) -> Void
    ) -> some View {
        if #available(iOS 17, *) {
            self.onChange(of: value) { _, newValue in action(newValue) }
        } else {
            self.onChange(of: value, perform: action)
        }
    }
}
