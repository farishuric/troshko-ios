//
//  CategoriesView.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

struct CategoriesView: View {
    // MARK: - View properties
    @ObservedObject private var categoriesVM = CategoriesViewModel(viewContext: CoreDataManager.shared.container.viewContext)
    
    @EnvironmentObject var expensesVM: ExpensesViewModel
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    List {
                        ForEach(categoriesVM.categories) { category in
                            Text(category.name ?? "WORDING_UNKNOWN".localized)
                                .swipeActions {
                                    Button {
                                        categoriesVM.categoryToDelete = category
                                        categoriesVM.isShowingDeletionAlert = true
                                    } label: {
                                        Text("WORDING_DELETE".localized)
                                    }
                                    .tint(.red)
                                }
                        }
                        .onChange(of: categoriesVM.categories) {
                            expensesVM.categories = $0
                        }
                    }
                    .overlay {
                        if categoriesVM.categories.isEmpty {
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.blue)
                                    
                                Text("CATEGORIES.NO_DATA".localized)
                            }
                        }
                    }
                }
                .navigationTitle("CATEGORIES.TITLE".localized)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            categoriesVM.isShowingAlert = true
                        } label: {
                            Image(systemName: "plus")
                                .renderingMode(.template)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .confirmationDialog(
                    "CATEGORIES.DELETION.TITLE".localized,
                    isPresented: $categoriesVM.isShowingDeletionAlert,
                    titleVisibility: .visible
                ) {
                    Button("WORDING_YES".localized, role: .destructive) {
                        if let category = categoriesVM.categoryToDelete {
                            withAnimation {
                                categoriesVM.delete(category: category) {
                                    expensesVM.fetchCategories()
                                }
                            }
                        }
                    }
                    .keyboardShortcut(.defaultAction)

                    Button("WORDING_NO".localized, role: .cancel) {
                        categoriesVM.categoryToDelete = nil
                    }
                } message: {
                    Text("CATEGORIES.DELETION.MESSAGE".localized)
                }
                
                .alert("CATEGORIES.ENTER.TITLE".localized, isPresented: $categoriesVM.isShowingAlert) {
                    TextField("CATEGORIES.PLACEHOLDER".localized, text: $categoriesVM.categoryName)
                    Button("WORDING_ADD".localized) {
                        withAnimation {
                            categoriesVM.saveCategory()
                            categoriesVM.fetchCategories()
                        }
                    }
                } message: {
                    Text("CATEGORIES.ENTER.MESSAGE".localized)
                }
                
            }
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
