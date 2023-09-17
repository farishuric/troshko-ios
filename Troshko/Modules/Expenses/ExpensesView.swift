//
//  ExpensesView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct TestModel: Hashable {
    var title: String
    var desc: String
    var price: String
}

struct ExpensesView: View {
    @State private var isPresentingAddExpenses: Bool = false
    
    let testModels: [TestModel] = [
    ]
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    List(testModels, id: \.self) {
                        ExpenseItemView(viewModel: $0)
                            .swipeActions(edge: .trailing) {
                                Button("WORDING_DELETE".localized) {
                                    print("Awesome!")
                                }
                                .tint(.red)
                            }
                        
                            .swipeActions(edge: .leading) {
                                Button("WORDING_EDIT".localized) {
                                    print("Awesome!")
                                }
                                .tint(.blue)
                            }
                    }
                    .overlay {
                        if testModels.isEmpty {
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.blue)
                                    
                                Text("No expenses found")
                            }
                        }
                    }
                    
                }
                .navigationTitle("EXPENSES.TITLE".localized)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isPresentingAddExpenses.toggle()
                        } label: {
                            Label("", systemImage: "plus")
                        }

                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingAddExpenses) {
            isPresentingAddExpenses = false
        } content: {
            AddExpensesView(isPresented: $isPresentingAddExpenses)
        }

        
    }
}

struct ExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
