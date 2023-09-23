//
//  MonthlyOverviewView.swift
//  Troshko
//
//  Created by Faris Hurić on 24. 9. 2023..
//

import SwiftUI
import DGCharts

struct MonthlyOverviewView: View {
    @StateObject var viewModel = MonthlyOverviewViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                PieChart()
                    .environmentObject(viewModel)
            }
            .navigationTitle("Monthly overview")
        }
    }
}

struct MonthlyOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyOverviewView()
    }
}
