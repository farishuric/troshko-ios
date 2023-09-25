//
//  Color + Extensions.swift
//  Troshko
//
//  Created by Faris Hurić on 25. 9. 2023..
//

import Foundation
import SwiftUI
import DGCharts

extension Color {

    static func getChartColors() -> [NSUIColor] {
        let colors: [NSUIColor] = [
            NSUIColor(.red),
            NSUIColor(.blue),
            NSUIColor(.green),
            NSUIColor(.yellow),
            NSUIColor(.orange),
            NSUIColor(.purple),
            NSUIColor(.indigo),
            NSUIColor(.pink)
        ]
        
        return colors
    }
}
