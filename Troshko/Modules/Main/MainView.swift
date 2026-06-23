//
//  MainView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct MainView: View {
    @State private var isPresentingSettings = false

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
        .environment(\.openSettings) {
            isPresentingSettings = true
        }
        .sheet(isPresented: $isPresentingSettings) {
            SettingsView(vm: SettingsViewModel())
                .presentationDetents([.medium, .large])
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
