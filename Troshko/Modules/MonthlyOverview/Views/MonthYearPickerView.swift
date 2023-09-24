//
//  MonthYearPickerView.swift
//  Troshko
//
//  Created by Faris Hurić on 24. 9. 2023..
//

import SwiftUI

struct MonthYearPickerView: View {
    @EnvironmentObject var viewModel: MonthlyOverviewViewModel
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Select a Month")
                        .font(.headline)
                        .padding()
                    Picker("Months", selection: $viewModel.selectedMonth) {
                        ForEach(Month.allCases, id: \.self) { month in
                            Text("\(month.title)")
                        }
                    }
                    .pickerStyle(.wheel) // Use .wheel style for the native picker
                    .padding()
                }
                
                VStack {
                    Text("Select a Year")
                        .font(.headline)
                        .padding()
                    Picker("Years", selection: $viewModel.selectedYear) {
                        ForEach(2020..<2024, id: \.self) { year in
                            Text(verbatim: "\(year)")
                        }
                    }
                    .pickerStyle(.wheel) // Use .wheel style for the native picker
                    .padding()
                }
            }
            Button {
                viewModel.isPickerPresented = false
            } label: {
                Text("Done")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

struct MonthYearPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MonthYearPickerView()
    }
}
