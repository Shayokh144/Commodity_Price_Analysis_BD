//
//  BarChartViewModel.swift
//  GraphComponent
//
//  Created by Taher on 25/1/24.
//

import Combine
import Foundation

final class BarChartViewModel: ObservableObject {

    @Published private(set) var barChartUIModel: [BarChartData]
    @Published private(set) var maxValueText: String
    @Published private(set) var minValueText: String
    @Published private(set) var avgValueText: String
    @Published private(set) var dataCountText: String
    @Published private(set) var lastPrice: String
    
    private let barChartData: [BarChartData]
    
    let chartName: String
    let timeFrame: String
    let weightUnitText: String
    let currencyUnitText: String
    let dataSource: String
    let xAxisName: String
    let yAxisName: String
    
    init(
        chartName: String,
        timeFrame: String,
        weightUnitText: String,
        currencyUnitText: String,
        dataSource: String,
        xAxisName: String,
        yAxisName: String,
        barChartData: [BarChartData]
    ) {
        self.chartName = chartName
        self.timeFrame = timeFrame
        self.weightUnitText = weightUnitText
        self.currencyUnitText = currencyUnitText
        self.dataSource = dataSource
        self.xAxisName = xAxisName
        self.yAxisName = yAxisName
        self.barChartData = barChartData
        barChartUIModel = []
        maxValueText = ""
        minValueText = ""
        avgValueText = ""
        dataCountText = ""
        lastPrice = ""
    }

    func onAppear() {
        let maxValueLength = barChartData.map { $0.name.count }.max() ?? 0
        let minValue = barChartData.map { $0.value }.min() ?? 0
        let maxValue = barChartData.map { $0.value }.max() ?? 1
        
        let minValueMonth = barChartData.first { $0.value == minValue }?.name ?? ""
        let maxValueMonth = barChartData.first { $0.value == maxValue }?.name ?? ""
        minValueText = "Minimum price: \(minValue)(\(minValueMonth))"
        maxValueText = "Maximum price: \(maxValue)(\(maxValueMonth))"
        var avg = 0.0
        barChartUIModel = barChartData.map { barChartData in
            let paddedName = String(repeating: " ", count: maxValueLength - barChartData.name.count + 1) + barChartData.name
            let mappedValue = (barChartData.value - minValue) / (maxValue - minValue) * 90 + 10
            avg += barChartData.value
            return BarChartData(
                name: paddedName,
                value: barChartData.value,
                calculatedValue: mappedValue
            )
        }
        dataCountText = "Total data points: \(barChartUIModel.count)"
        avg /= Double(barChartUIModel.count)
        avgValueText = "Average price: \(avg.rounded(toPlaces: 2))"
        lastPrice = "Latest price: \(String(barChartUIModel.last?.value ?? 0)) from \(barChartUIModel.last?.name ?? "")"
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
