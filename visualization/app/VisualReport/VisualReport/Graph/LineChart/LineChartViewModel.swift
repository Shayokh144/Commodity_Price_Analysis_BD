//
//  LineChartViewModel.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 19/8/24.
//

import Foundation

final class LineChartViewModel: ObservableObject {
    
    @Published var uiModels: [LineChartDataSeries]
    @Published var uiFirstDate: Date?
    @Published var uiLastDate: Date?
    let viewModelData: LineChartViewModelData
    
    init(lineChartViewModelData: LineChartViewModelData) {
        uiModels = []
        viewModelData = lineChartViewModelData
    }

    func createDataModel() {
        guard uiModels.isEmpty else {
            return
        }
        guard let firstDate = viewModelData.lineChartDataList.first?.xTimeValue,
              let lastDate = viewModelData.lineChartDataList.last?.xTimeValue else {
            return
        }
        uiFirstDate = firstDate
        uiLastDate = lastDate
        let ruleMarks = getRuleMarkList(
            chartDataPoints: viewModelData.lineChartDataList
        )
        let uiModel = LineChartDataSeries(
            type: "All year",
            firstDate: firstDate,
            lastDate: lastDate,
            lineChartDataList: viewModelData.lineChartDataList,
            ruleMarkDataList: ruleMarks
        )
        uiModels = [uiModel]
    }
    
    private func getRuleMarkList(
        chartDataPoints: [LineChartDataModel]
    ) -> [RuleMarkDataModel] {
        let avgValue: Double = chartDataPoints.reduce(0.0) {
            return $1.yValue + $0
        } / Double(chartDataPoints.count)
        return [
            RuleMarkDataModel(
                id: 1, 
                yValue: avgValue,
                yName: "Average price:",
                ruleMarkName: "Average price"
            )
        ]
    }
}

struct LineChartViewModelData {
    
    let chartName: String
    let timeFrame: String
    let weightUnitText: String
    let currencyUnitText: String
    let dataSource: String
    let lineChartDataList: [LineChartDataModel]
}
