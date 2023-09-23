//
//  PieChartView.swift
//  Troshko
//
//  Created by Faris Hurić on 24. 9. 2023..
//

import Foundation
import DGCharts
import SwiftUI

struct PieChart: UIViewRepresentable {
    @EnvironmentObject var viewModel: MonthlyOverviewViewModel
    
    let pieChart = PieChartView()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> PieChartView {
        pieChart.delegate = context.coordinator
        pieChart.noDataText = "No Data"
                        
        pieChart.legend.enabled = false
        pieChart.drawEntryLabelsEnabled = true
    
        pieChart.usePercentValuesEnabled = false
        pieChart.sliceTextDrawingThreshold = 0
        pieChart.holeColor = .clear
        pieChart.transparentCircleColor = .clear
        pieChart.drawSlicesUnderHoleEnabled = false
        
        pieChart.isUserInteractionEnabled = false
        
        return pieChart
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        let dataSet = PieChartDataSet(entries: viewModel.entries)
        dataSet.label = "Kategorije"
        dataSet.colors = ChartColorTemplates.vordiplom()
        dataSet.drawIconsEnabled = false
        
        dataSet.valueColors = [.black]
        
        let legend = uiView.legend
        legend.enabled = true
        legend.xOffset = 16
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .bottom
        legend.orientation = .vertical
        legend.font = .systemFont(ofSize: 14)
        
        uiView.data = PieChartData(dataSet: dataSet)
        
        uiView.notifyDataSetChanged()
    }
    
    class Coordinator: NSObject, ChartViewDelegate {
        let parent: PieChart
        
        init(parent: PieChart) {
            self.parent = parent
        }
    }
}
