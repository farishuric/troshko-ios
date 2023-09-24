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
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        viewModel.isPickerPresented.toggle()
//                    }) {
//                        Label("Date", systemImage: "chevron.down")
//                    }
//                    .buttonStyle(.bordered)
//                    .tint(.black)
//                }.padding(.horizontal, 16)
                
                Spacer()
                VStack {
                    if viewModel.entries.isEmpty {
                        Text("NO_DATA".localized)
                    } else {
                        
                        PieChart()
                            .environmentObject(viewModel)
                    }
                    
                    HStack {
                        Spacer()
                        Text(verbatim: "MONTHLY_OVERVIEW.TOTAL_EXPENSES".localized(arguments: "\(viewModel.totalExpenses) \(Locale.current.currencySymbol ?? "")"))
                            .padding()
                    }
                }
                Spacer()
            }
            .navigationTitle("MONTHLY_OVERVIEW.NAV_TITLE")
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
