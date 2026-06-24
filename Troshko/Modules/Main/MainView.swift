//
//  MainView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import DI
import SwiftUI
import Styleguide
import UIKit

struct MainView: View {
    @State private var isPresentingSettings = false
    @State private var didAttemptDemoDataSeed = false
    @State private var isDemoDataReady = !DemoDataConfiguration.isEnabled

    @Injected private var seedDemoData: SeedDemoDataUseCase

    init() {
        Self.configureTabBarAppearance()
    }

    var body: some View {
        content
            .task {
                await seedDemoDataIfNeeded()
            }
    }

    @ViewBuilder
    private var content: some View {
        if isDemoDataReady {
            tabs
        } else {
            BaseScreen(isLoading: true, showsAmbientBackground: true) {
                EmptyView()
            }
        }
    }

    private var tabs: some View {
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
        .fullScreenCover(isPresented: $isPresentingSettings) {
            SettingsView(vm: SettingsViewModel())
        }
    }

    @MainActor
    private func seedDemoDataIfNeeded() async {
        guard DemoDataConfiguration.isEnabled else {
            isDemoDataReady = true
            return
        }
        guard !didAttemptDemoDataSeed else { return }
        didAttemptDemoDataSeed = true
        if DIContainer.shared.isRegistered(SeedDemoDataUseCase.self) {
            try? await seedDemoData.execute()
        }
        isDemoDataReady = true
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
