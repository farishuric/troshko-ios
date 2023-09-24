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
        NavigationView {
            VStack {
                HStack {
                    VStack {
                        Text("PICKER.SELECT_MONTH".localized)
                            .font(.headline)
                            .padding()
                        Picker("Months", selection: $viewModel.selectedMonth) {
                            ForEach(0..<13, id: \.self) { month in
                                if let month = Month(rawValue: month) {
                                    Text(month.title)
                                }
                            }
                        }
                        .pickerStyle(.wheel) // Use .wheel style for the native picker
                        .padding()
                    }
                    
                    VStack {
                        Text("PICKER.SELECT_YEAR".localized)
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
                    viewModel.createDate()
                    viewModel.isPickerPresented = false
                } label: {
                    Text("WORDING_APPLY".localized)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.isPickerPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 16.0, height: 16.0)
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
        }
    }
}

struct MonthYearPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MonthYearPickerView()
    }
}
