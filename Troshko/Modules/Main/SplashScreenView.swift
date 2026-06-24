//
//  SplashScreenView.swift
//  Troshko
//
//  Created by Assistant
//

import SwiftUI
import Styleguide

struct SplashScreenView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isActive = false
    @State private var logoScale: CGFloat = Metrics.initialLogoScale
    @State private var logoOpacity: Double = 0
    @State private var glowScale: CGFloat = Metrics.initialGlowScale
    @State private var glowOpacity: Double = 0
    @State private var lift: CGFloat = Spacing.Semantic.componentMargin

    var body: some View {
        if isActive {
            MainView()
        } else {
            ZStack {
                Circle()
                    .strokeBorder(
                        SemanticColor.Colors.plainWhite.swiftUIColor.opacity(glowOpacity),
                        lineWidth: Spacing.Semantic.borderWidth
                    )
                    .frame(width: Metrics.glowSize, height: Metrics.glowSize)
                    .scaleEffect(glowScale)
                    .blur(radius: Spacing.Semantic.shadowRadius)

                Circle()
                    .fill(SemanticColor.Colors.plainWhite.swiftUIColor.opacity(glowOpacity * Metrics.glowFillOpacity))
                    .frame(width: Metrics.glowSize, height: Metrics.glowSize)
                    .scaleEffect(glowScale)

                Image("troshko_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Metrics.logoSize, height: Metrics.logoSize)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .offset(y: reduceMotion ? 0 : lift)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SemanticColor.Colors.primary.swiftUIColor)
            .ignoresSafeArea()
            .onAppear(perform: startAnimation)
        }
    }

    private func startAnimation() {
        if reduceMotion {
            logoScale = 1
            logoOpacity = 1
            glowScale = 1
            glowOpacity = Metrics.finalGlowOpacity
            lift = 0
        } else {
            withAnimation(Motion.drift) {
                logoScale = 1
                logoOpacity = 1
                lift = 0
            }

            withAnimation(Motion.fade.delay(Motion.Duration.quick)) {
                glowOpacity = Metrics.finalGlowOpacity
            }

            withAnimation(Motion.drift.delay(Motion.Duration.quick)) {
                glowScale = Metrics.finalGlowScale
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Metrics.visibleDuration) {
            withAnimation(Motion.resolved(Motion.fade, reduceMotion: reduceMotion)) {
                isActive = true
            }
        }
    }
}

private enum Metrics {
    static let logoSize: CGFloat = 250
    static let glowSize: CGFloat = 300
    static let initialLogoScale: CGFloat = 0.88
    static let initialGlowScale: CGFloat = 0.72
    static let finalGlowScale: CGFloat = 1.08
    static let finalGlowOpacity: Double = 0.42
    static let glowFillOpacity: Double = 0.18
    static let visibleDuration: TimeInterval = 2.3
}

#Preview {
    SplashScreenView()
}
