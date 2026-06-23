//
//  MainView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI
import Styleguide
import UIKit

struct MainView: View {
    @State private var isPresentingSettings = false

    init() {
        Self.configureTabBarAppearance()
    }

    var body: some View {
        TabView {
            HomeView(vm: HomeViewModel())
                .tabItem {
                    Label("HOME.TITLE".localized, systemImage: "house.fill")
                }
            // Migrated to Clean Architecture (Phase 1). Owns its own ViewModel via DI.
            ExpensesView(vm: ExpensesViewModel())
                .tabItem {
                    Label("EXPENSES.TITLE".localized, systemImage: "creditcard")
                }
            MonthlyOverviewView(vm: MonthlyOverviewViewModel())
                .tabItem {
                    Label("MONTHLY_OVERVIEW.TITLE".localized, systemImage: "chart.pie")
                }
        }
        .tint(SemanticColor.Colors.primary.swiftUIColor)
        .environment(\.openSettings) {
            isPresentingSettings = true
        }
        .sheet(isPresented: $isPresentingSettings) {
            SettingsView(vm: SettingsViewModel())
                .presentationDetents([.medium, .large])
                .presentationBackground(.ultraThinMaterial)
        }
    }

    private static func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = SemanticColor.Colors.surfaceCard.color.withAlphaComponent(0.82)
        appearance.shadowColor = SemanticColor.Colors.borderPrimary.color.withAlphaComponent(0.4)

        let selectedColor = SemanticColor.Colors.primary.color
        let normalColor = SemanticColor.Colors.textSecondary.color

        [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance
        ].forEach { itemAppearance in
            itemAppearance.selected.iconColor = selectedColor
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
            itemAppearance.normal.iconColor = normalColor
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = selectedColor
        UITabBar.appearance().unselectedItemTintColor = normalColor
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
