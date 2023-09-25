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
                               
                Text("\(viewModel.date?.format(with: .short) ?? Date().format(with: .short))")
                    .font(.system(.caption))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(viewModel.price.toString(decimal: 2))\(Locale.current.currencySymbol ?? "")")
                    .font(.system(.title2))
                
                BadgeView(text: viewModel.category?.name ?? "WORDING_UNKNOWN".localized)
            }
        }
    }
}

struct ExpenseItemView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseItemView(viewModel: Expense(context: CoreDataManager.shared.container.viewContext))
    }
}
