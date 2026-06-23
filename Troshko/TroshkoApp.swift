//
//  TroshkoApp.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI
// Shared infrastructure (ported from the Aisthesis architecture — see CLAUDE.md).
import DI
import MVVM
import Networking
import Extension
import Styleguide

@main
struct TroshkoApp: App {
    @AppStorage(AppAppearance.storageKey) private var appearanceRawValue = AppAppearance.system.rawValue

    init() {
        FontRegistrar.registerFonts()
        AppDependencies.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(AppAppearance(rawValue: appearanceRawValue)?.colorScheme)
        }
    }
}

/// Composition root for the app.
///
/// Each feature registers its own dependencies here via a `<Feature>DependencyContainer`
/// (added during the per-feature migration, Phase 1+). Phase 0 only stands up the
/// container so the DI infrastructure is wired and ready.
enum AppDependencies {
    static func registerAll() {
        SettingsDependencyContainer.register()
        ExpensesDependencyContainer.register()
        // Depends on Expenses' GetExpensesUseCase for saved-this-month math.
        HomeDependencyContainer.register()
        CategoriesDependencyContainer.register()
        // Depends on Expenses' GetExpensesUseCase — register after Expenses.
        MonthlyOverviewDependencyContainer.register()
    }
}

private extension AppAppearance {
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
