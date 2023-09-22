//
//  AddCategoriesView.swift
//  Troshko
//
//  Created by Edhem Silajdzic on 22. 9. 2023..
//

import SwiftUI

struct AddCategoriesView: View {
    @EnvironmentObject var addCategoryVM: CategoriesViewModel
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("CATEGORIES.INFORMATION".localized).textCase(nil)) {
                    TextField("CATEGORIES.NAME".localized, text: $addCategoryVM.categoryName)
                        .focused($isFocused)
                    
                    Text("CATEGORIES.DESCRIPTION".localized)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section(footer: Button(action: {
                    addCategoryVM.saveCategory()
                }) {
                    Text("WORDING_SAVE".localized)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(addCategoryVM.isAddDisabled ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.disabled(addCategoryVM.isAddDisabled)) {
                    EmptyView()
                }
            }
            .navigationBarTitle("CATEGORIES.ADD.CATEGORY".localized, displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                addCategoryVM.isShowingAlert = false
            }) {
                Text("WORDING_CANCEL".localized)
            })
        }.onAppear() {
            isFocused = true
        }
    }
}

struct AddCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoriesView()
            .environmentObject(CategoriesViewModel(viewContext: CoreDataManager.shared.container.viewContext))
    }
}
