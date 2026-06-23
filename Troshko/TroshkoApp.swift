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
    init() {
        AppDependencies.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
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
        ExpensesDependencyContainer.register()
        CategoriesDependencyContainer.register()
        // Depends on Expenses' GetExpensesUseCase — register after Expenses.
        MonthlyOverviewDependencyContainer.register()
    }
}
