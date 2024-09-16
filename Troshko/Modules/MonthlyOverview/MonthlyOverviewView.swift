//
//  MonthlyOverviewView.swift
//  Troshko
//
//  Created by Faris Hurić on 24. 9. 2023..
//

import SwiftUI
import DGCharts

struct MonthlyOverviewView: View {
    @StateObject var viewModel = MonthlyOverviewViewModel()
    
    var body: some View {
        NavigationView {
            VStack {  
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.isPickerPresented.toggle()
                    }) {
                        Label("\(viewModel.selectedDate.format(with: .monthYear))".capitalized, systemImage: "chevron.down")
                    }
                    .buttonStyle(.bordered)
                    .tint(.gray)
                    .foregroundColor(.primary)
                }.padding(.horizontal, 16)
                
                Spacer()
                VStack {
                    Spacer()
                    if viewModel.entries.isEmpty {
                        ZStack(alignment: .topTrailing) {
                            EmptyStateView(systemImage: "chart.pie", text: "MONTHLY_OVERVIEW.NO_DATA".localized)
                        }
                    } else {
                        
                        PieChart()
                            .environmentObject(viewModel)
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text(verbatim: "MONTHLY_OVERVIEW.TOTAL_EXPENSES".localized(
                            arguments: "\(viewModel.totalExpenses) \(Locale.current.currencySymbol ?? "")")
                        )
                        .padding()
                    }
                }
                Spacer()
            }
            .onAppear {
                viewModel.fetchCategoriesWithExpenses(for: Date())
            }
            .onChange(of: viewModel.selectedDate) { newValue in
                viewModel.fetchCategoriesWithExpenses(for: newValue)
            }
            .sheet(isPresented: $viewModel.isPickerPresented) {
                MonthYearPickerView()
                    .environmentObject(viewModel)
            }
        }
    }
}

struct MonthlyOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyOverviewView()
    }
}
