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
                            Text(category.name ?? "WORDING_UNKNOWN".localized)
                                .swipeActions {
                                    Button {
                                        withAnimation {
                                            categoriesVM.delete(category: category)
                                        }
                                    } label: {
                                        Text("WORDING_DELETE".localized)
                                    }
                                    .tint(.red)
                                }
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
                .alert("CATEGORIES.ENTER.TITLE".localized, isPresented: $categoriesVM.isShowingAlert) {
                    TextField("CATEGORIES.PLACEHOLDER".localized, text: $categoriesVM.categoryName)
                    Button {
                        withAnimation {
                            categoriesVM.saveCategory()
                            categoriesVM.fetchCategories()
                        }
                    } label: {
                        Text("WORDING_ADD".localized)
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
