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

    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    List {
                        ForEach(categoriesVM.categories) { category in
                            NavigationLink {
                                CategoryExpensesView(categoryName: category.name ?? "")
                            } label: {
                                Text(category.name ?? "WORDING_UNKNOWN".localized)
                            }
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
                    }
                    .overlay {
                        if categoriesVM.categories.isEmpty {
                            EmptyStateView(systemImage: "doc.text", text: "CATEGORIES.NO_DATA".localized)
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
                    Button("WORDING_DELETE".localized, role: .destructive) {
                        if let category = categoriesVM.categoryToDelete {
                            withAnimation {
                                categoriesVM.delete(category: category) { }
                            }
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    
                    Button("WORDING_CANCEL".localized, role: .cancel) {
                        categoriesVM.categoryToDelete = nil
                    }
                } message: {
                    Text("CATEGORIES.DELETION.MESSAGE".localized)
                }
            }
            .sheet(isPresented: $categoriesVM.isShowingAlert) {
                categoriesVM.isShowingAlert = false
            } content: {
                AddCategoriesView()
                .environmentObject(categoriesVM)
                    .onDisappear {
                        categoriesVM.fetchCategories()
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
