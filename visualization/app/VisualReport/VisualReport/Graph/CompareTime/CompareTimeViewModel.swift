//
//  CompareTimeViewModel.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 9/12/24.
//

import Foundation

class CompareTimeViewModel: ObservableObject {
    
    @Published var compareTimeDataSeries: [CompareTimeDataSeries] = []
    @Published var selectedStartMonth: String = ""
    @Published var selectedEndMonth: String = ""
    @Published var startMonths: [String] = []
    @Published var endMonths: [String] = []
    @Published var errorMessage: String?
    @Published var chartYAxisValues: [Int] = []
    @Published var minYValue = 99999999
    @Published var maxYValue = 0
    let productName: String
    let lineChartDataList: [LineChartDataModel]
    let quantity: String
    let timeFrame: String
    
    init(
        lineChartDataList: [LineChartDataModel],
        productName: String,
        quantity: String,
        timeFrame: String
    ) {
        self.productName = productName
        self.lineChartDataList = lineChartDataList
        self.quantity = quantity.components(separatedBy: "+-").first ?? ""
        self.timeFrame = timeFrame
        populateCompareTimeDataSeries(lineChartDataList: lineChartDataList)
        startMonths = getEnglishMonths()
        endMonths = getEnglishMonths()
        selectedStartMonth = startMonths.first ?? ""
        selectedEndMonth = endMonths.first ?? ""
    }
    
    func filter() {
        populateCompareTimeDataSeries(lineChartDataList: lineChartDataList)
    }
    
    private func populateCompareTimeDataSeries(lineChartDataList: [LineChartDataModel]) {
        compareTimeDataSeries.removeAll()
        var oldTimeData2022: [CompareTimeData] = []
        var oldTimeData2023: [CompareTimeData] = []
        var currentTimeData: [CompareTimeData] = []
        let fromMonth = getMonthInt(selected: selectedStartMonth, months: startMonths)
        let toMonth = getMonthInt(selected: selectedEndMonth, months: endMonths)
        if fromMonth > toMonth {
            errorMessage = "End month should be greater than start month"
            return
        }
        errorMessage = nil
        let calendar = Calendar.current
        minYValue = 99999999
        maxYValue = 0
        for lineChartData in lineChartDataList {
            let year = calendar.component(.year, from: lineChartData.xTimeValue)
            let month = calendar.component(.month, from: lineChartData.xTimeValue)
            var computedDateStr = DateFormatter.dayMonth.string(from: lineChartData.xTimeValue)
            computedDateStr += "-2024" // for X axis we need same date range other wise it will plot based on date
            let computedDate = DateFormatter.dayMonthYear.date(from: computedDateStr) ?? Date()
            if year == 2022 && month >= fromMonth && month <= toMonth {
                oldTimeData2022.append(
                    .init(
                        time: computedDate,
                        value: lineChartData.yValue,
                        id: lineChartData.xTimeValue
                    )
                )
                minYValue = minYValue < Int(lineChartData.yValue) ? minYValue : Int(lineChartData.yValue)
                maxYValue = maxYValue > Int(lineChartData.yValue) ? maxYValue : Int(lineChartData.yValue)
            } else if year == 2023 && month >= fromMonth && month <= toMonth {
                oldTimeData2023.append(
                    .init(
                        time: computedDate,
                        value: lineChartData.yValue,
                        id: lineChartData.xTimeValue
                    )
                )
                minYValue = minYValue < Int(lineChartData.yValue) ? minYValue : Int(lineChartData.yValue)
                maxYValue = maxYValue > Int(lineChartData.yValue) ? maxYValue : Int(lineChartData.yValue)
            } else if year == 2024 && month >= fromMonth && month <= toMonth {
                currentTimeData.append(
                    .init(
                        time: computedDate,
                        value: lineChartData.yValue,
                        id: lineChartData.xTimeValue
                    )
                )
                minYValue = minYValue < Int(lineChartData.yValue) ? minYValue : Int(lineChartData.yValue)
                maxYValue = maxYValue > Int(lineChartData.yValue) ? maxYValue : Int(lineChartData.yValue)
            }
        }
        minYValue -= 20
        maxYValue += 20
        let difference = (maxYValue - minYValue) / 15
        chartYAxisValues = stride(from: minYValue, to: maxYValue, by: difference).map { $0 }
        let oldDataSeries22 = CompareTimeDataSeries(type: "2022", timeData: oldTimeData2022)
        let oldDataSeries23 = CompareTimeDataSeries(type: "2023", timeData: oldTimeData2023)
        let currentDataSeries = CompareTimeDataSeries(type: "2024", timeData: currentTimeData)
        compareTimeDataSeries.append(oldDataSeries22)
        compareTimeDataSeries.append(oldDataSeries23)
        compareTimeDataSeries.append(currentDataSeries)
        if minYValue >= maxYValue {
            maxYValue = minYValue + 10
        }
    }
    
    private func getEnglishMonths() -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US") // Ensures English locale
        return dateFormatter.monthSymbols
    }
    
    private func getMonthInt(selected: String, months: [String]) -> Int {
        if let index = months.firstIndex(of: selected) {
            return index + 1
        } else {
            return 1
        }
    }
}
