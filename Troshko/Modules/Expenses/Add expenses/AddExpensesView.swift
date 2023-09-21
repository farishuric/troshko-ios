//
//  AddExpensesView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct AddExpensesView: View {
    @ObservedObject private var addExpensesVM = AddExpensesViewModel(viewContext: CoreDataManager.shared.container.viewContext)
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("ADD_EXPENSE.TITLE.PLACEHOLDER".localized, text: $addExpensesVM.title)
                        .submitLabel(.next)
                } header: {
                    Text("ADD_EXPENSE.TITLE".localized)
                }

                Section {
                    TextField("ADD_EXPENSE.DESCRIPTION.PLACEHOLDER".localized, text: $addExpensesVM.description)
                        .submitLabel(.next)
                } header: {
                    Text("ADD_EXPENSE.DESCRIPTION".localized)
                }
                
                Section {
                    HStack(spacing: 4) {
                        Text("\(Locale.current.currencySymbol ?? "")")
                        TextField("0.0", text: $addExpensesVM.price)
                    }
                } header: {
                    Text("ADD_EXPENSE.PRICE".localized)
                }
                
                Section {
                    DatePicker("", selection: $addExpensesVM.selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                } header: {
                    Text("ADD_EXPENSE.DATE".localized)
                }

            }
            .navigationBarTitle("ADD_EXPENSE".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("WORDING_CANCEL".localized) {
                        isPresented = false
                    }
                    .tint(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("WORDING_ADD".localized) {
                        addExpensesVM.saveExpense {
                            isPresented = false
                        }
                    }
                    .disabled(addExpensesVM.isAddDisabled)
                }
            }
        }
    }

}

struct AddExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpensesView(isPresented: .constant(true))
    }
}
