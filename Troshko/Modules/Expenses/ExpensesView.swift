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
        TestModel(
            title: "iPhone 13 Pro",
            desc: "The latest iPhone model with advanced features.",
            price: "999.99"
        ),
        TestModel(
            title: "MacBook Air",
            desc: "A lightweight and powerful laptop for everyday use.",
            price: "1,199.00"
        ),
        TestModel(
            title: "Sony 65-Inch 4K Ultra HD Smart LED TV",
            desc: "A high-quality 4K TV with smart features.",
            price: "1,299.99"
        ),
        TestModel(
            title: "Bose QuietComfort 35 II Wireless Headphones",
            desc: "Noise-canceling headphones for immersive audio experience.",
            price: "299.00"
        ),
        TestModel(
            title: "Dyson V11 Animal Cordless Vacuum Cleaner",
            desc: "A powerful cordless vacuum for pet owners.",
            price: "599.99"
        ),
        // Add more dummy data as needed
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
