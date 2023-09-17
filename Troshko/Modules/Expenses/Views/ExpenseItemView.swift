//
//  ExpenseItemView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct ExpenseItemView: View {
    var viewModel: TestModel
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .font(.system(.title3))
                Text(viewModel.desc)
                    .font(.system(.caption))
                    .foregroundColor(.secondary)
                
                BadgeView(text: "Category")
            }
            
            Spacer()
            
            VStack {
                Text("\(viewModel.price)\(Locale.current.currencySymbol ?? "")")
                    .font(.system(.title2))
            }
        }
    }
}

struct ExpenseItemView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseItemView(viewModel: .init(title: "Test", desc: "Testing", price: "24"))
            .previewLayout(.sizeThatFits)
    }
}
