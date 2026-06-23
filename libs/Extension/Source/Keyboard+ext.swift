//
//
//  Keyboard+ext.swift
//  Extension
//
//  Created by Fare
//
    


import SwiftUI

public extension View {
    func hideKeyboardOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.dismissKeyboardUnlessFocusMoves()
            }
        )
    }
}

private extension UIApplication {
    func dismissKeyboardUnlessFocusMoves() {
        guard let firstResponder = keyWindow?.firstResponder else { return }

        DispatchQueue.main.async {
            guard firstResponder.isFirstResponder else { return }
            firstResponder.resignFirstResponder()
        }
    }

    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}

private extension UIView {
    var firstResponder: UIView? {
        if isFirstResponder {
            return self
        }

        return subviews.lazy.compactMap(\.firstResponder).first
    }
}
