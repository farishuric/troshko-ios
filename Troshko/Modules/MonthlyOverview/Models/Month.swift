//
//  Month.swift
//  Troshko
//
//  Created by Faris Hurić on 24. 9. 2023..
//

import Foundation

enum Month: Int, CaseIterable {
    case january, february, march, april, may, june, july, august, september, october, november, december
    
    var title: String {
        switch self {
        case .january: return "January"
        case .february: return "February"
        case .march: return "March"
        case .april: return "April"
        case .may: return "May"
        case .june: return "June"
        case .july: return "July"
        case .august: return "August"
        case .september: return "September"
        case .october: return "October"
        case .november: return "November"
        case .december: return "December"
        }
    }
}
