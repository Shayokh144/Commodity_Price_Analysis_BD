//
//  LineChartDataModel.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 18/8/24.
//

import Foundation

struct LineChartDataSeries: Identifiable {
    
    let id = UUID()
    let type: String
    var firstDate: Date
    var lastDate: Date
    var lineChartDataList: [LineChartDataModel]
    var ruleMarkDataList: [RuleMarkDataModel]
}


struct LineChartDataModel: Identifiable {
    
    var id: Int
    let xTimeValue: Date
    let yValue: Double
}

struct RuleMarkDataModel: Identifiable {
    
    let id: Int
    let yValue: Double
    let yName: String
    let ruleMarkName: String
}
