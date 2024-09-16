import SwiftUI

enum NavigationState {
    case expenses
    case categories
    case monthlyOverview
}

struct MainView: View {
    @StateObject var expensesVM = ExpensesViewModel(viewContext: CoreDataManager.shared.container.viewContext)
    @State private var navigationState: NavigationState = .expenses

    var body: some View {
        NavigationStack {
            TabView {
                ExpensesView()
                    .environmentObject(expensesVM)
                    .tabItem {
                        Label("EXPENSES.TITLE".localized, systemImage: "creditcard")
                    }
                    .onAppear {
                        navigationState = .expenses
                    }

                CategoriesView()
                    .environmentObject(expensesVM)
                    .tabItem {
                        Label("CATEGORIES.TITLE".localized, systemImage: "archivebox.fill")
                    }
                    .onAppear {
                        navigationState = .categories
                    }

                MonthlyOverviewView()
                    .tabItem {
                        Label("MONTHLY_OVERVIEW.TITLE".localized, systemImage: "chart.pie")
                    }
                    .onAppear {
                        navigationState = .monthlyOverview
                    }
            }
            .navigationTitle(titleForState(navigationState))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }

                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    switch navigationState {
                    case .expenses:
                        Button {
                            expensesVM.isPresentingAddExpenses.toggle()
                        } label: {
                            Label("Add Expense", systemImage: "plus")
                        }
                    case .categories:
                        Button {
                            // Define your action for categories
                        } label: {
                            Label("Categories Action", systemImage: "star")
                        }
                    case .monthlyOverview:
                        Button {
                            // Define your action for monthly overview
                        } label: {
                            Label("Monthly Action", systemImage: "calendar")
                        }
                    }
                }
            }
        }
    }

    private func titleForState(_ state: NavigationState) -> String {
        switch state {
        case .expenses:
            return "EXPENSES.TITLE".localized
        case .categories:
            return "CATEGORIES.TITLE".localized
        case .monthlyOverview:
            return "MONTHLY_OVERVIEW.NAV_TITLE".localized
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
