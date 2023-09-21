//
//  ExpenseItemView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct ExpenseItemView: View {
    var viewModel: Expense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                Text(viewModel.title ?? "WORDING_UNKOWN".localized)
                    .font(.system(.title3))
                
                Text(viewModel.desc ?? "WORDING_UNKOWN".localized)
                    .font(.system(.caption))
                    .foregroundColor(.secondary)
                
                BadgeView(text: "Category")
            }
            
            Spacer()
            
            VStack {
                Text("\(viewModel.price.toString(decimal: 2))\(Locale.current.currencySymbol ?? "")")
                    .font(.system(.title2))
                
                Text("\(viewModel.date?.format(with: .shortDateTime) ?? "14.11.2023")")
                    .font(.system(.caption))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ExpenseItemView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseItemView(viewModel: Expense(context: .init(concurrencyType: .mainQueueConcurrencyType)))
    }
}
