//
//  CompareTimeDataSeries.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 9/12/24.
//

import Foundation

struct CompareTimeDataSeries: Identifiable {
    
    let type: String
    let timeData: [CompareTimeData]
    var id: String { type }
}

struct CompareTimeData: Identifiable {
    
    let time: Date
    let value: Double
    var id: Date
}
