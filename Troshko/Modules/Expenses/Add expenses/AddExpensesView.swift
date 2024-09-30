//
//  AddExpensesView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct AddExpensesView: View {
    @EnvironmentObject var expensesVM: ExpensesViewModel
    @FocusState private var focusedField: ExpensesFocusedField?
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Category selection
                Section {
                    Picker("ADD_EXPENSE.CATEGORY_PLACEHOLDER".localized, selection: $expensesVM.selectedCategory) {
                        if expensesVM.categories.isEmpty {
                            Text("WORDING_NONE".localized)
                                .tag(0)
                        } else {
                            ForEach(expensesVM.categories, id: \.self) { category in
                                Text(category.name ?? "")
                                    .tag(expensesVM.categories.firstIndex(where: { $0 == category }) ?? 0)
                            }
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("ADD_EXPENSE.CATEGORY".localized)
                }
                
                // MARK: - Expense title
                Section {
                    TextField("ADD_EXPENSE.TITLE.PLACEHOLDER".localized, text: $expensesVM.title)
                        .submitLabel(.next)
                } header: {
                    Text("ADD_EXPENSE.TITLE".localized)
                }
                
                // MARK: - Description
                Section {
                    TextField("ADD_EXPENSE.DESCRIPTION.PLACEHOLDER".localized, text: $expensesVM.description)
                        .submitLabel(.next)
                } header: {
                    Text("ADD_EXPENSE.DESCRIPTION".localized)
                }
                
                // MARK: - Price
                Section {
                    VStack(alignment: .leading) {
                        HStack(spacing: 4) {
                            Text("\(Locale.current.currencySymbol ?? "")")
                            TextField("0.0", text: $expensesVM.price)
                                .keyboardType(UIKeyboardType.decimalPad)
                                .submitLabel(.done)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Button {
                                            endEditing()
                                            expensesVM.validatePrice()
                                        } label: {
                                            Text("WORDING_DONE".localized)
                                        }
                                    }
                                }
                                .onSubmit {
                                    expensesVM.validatePrice()
                                }
                                .focused($focusedField, equals: .price)
                        }
                        
                        if expensesVM.priceErrorState != nil {
                            withAnimation {
                                ErrorMessageView(errorState: $expensesVM.priceErrorState)
                            }
                        }
                        
                    }
                } header: {
                    Text("ADD_EXPENSE.PRICE".localized)
                }
                
                // MARK: - Date pick
                Section {
                    DatePicker("", selection: $expensesVM.selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .onTapGesture(count: 99) {
                            }
                } header: {
                    Text("ADD_EXPENSE.DATE".localized)
                }
            }
            .navigationBarTitle("ADD_EXPENSE".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("WORDING_CANCEL".localized) {
                        expensesVM.isPresentingAddExpenses = false
                    }
                    .tint(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(expensesVM.isEditing ? "WORDING_SAVE".localized : "WORDING_ADD".localized) {
                        if expensesVM.isEditing {
                            expensesVM.editExpense {
                                expensesVM.isPresentingAddExpenses = false
                            }
                        } else {
                            expensesVM.saveExpense {
                                expensesVM.price = ""
                                expensesVM.isPresentingAddExpenses = false
                            }
                        }
                        
                    }
                    .disabled(expensesVM.isAddDisabled)
                }
            }
        }
        .onTapGesture {
            endEditing()
            if let focusedField, focusedField == .price {
                expensesVM.validatePrice()
            }
        }
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
}

struct AddExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpensesView()
            .environmentObject(ExpensesViewModel(viewContext: CoreDataManager.shared.container.viewContext))
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ErrorMessageView: View {
    @Binding var errorState: ErrorState?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let errorMessage = errorState?.message {
                HStack {
                    Image(systemName: "x.circle")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.default, value: errorState)
            }
        }
    }
}
