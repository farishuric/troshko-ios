import SwiftUI
import Styleguide

/// Month + year wheel picker presented as a sheet. Writes the chosen month back to
/// `selectedDate` (anchored to day 1) on apply.
struct MonthYearPickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss

    @State private var month: Int
    @State private var year: Int

    private static let firstYear = 2020
    private let lastYear = Calendar.current.component(.year, from: Date()) + 5

    init(selectedDate: Binding<Date>) {
        _selectedDate = selectedDate
        let calendar = Calendar.current
        _month = State(initialValue: calendar.component(.month, from: selectedDate.wrappedValue))
        _year = State(initialValue: calendar.component(.year, from: selectedDate.wrappedValue))
    }

    private var monthSymbols: [String] {
        DateFormatter().standaloneMonthSymbols
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Picker("PICKER.SELECT_MONTH".localized, selection: $month) {
                        ForEach(1...12, id: \.self) { number in
                            Text(monthSymbols[number - 1].capitalized).tag(number)
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker("PICKER.SELECT_YEAR".localized, selection: $year) {
                        ForEach(Self.firstYear...lastYear, id: \.self) { value in
                            Text(verbatim: "\(value)").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                }

                PrimaryButton(action: apply) {
                    Text("WORDING_APPLY".localized)
                }
                .padding(Spacing.Semantic.screenMargin)
            }
            .navigationTitle("MONTHLY_OVERVIEW.NAV_TITLE".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("WORDING_CANCEL".localized) { dismiss() }
                }
            }
        }
    }

    private func apply() {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            selectedDate = date
        }
        dismiss()
    }
}
