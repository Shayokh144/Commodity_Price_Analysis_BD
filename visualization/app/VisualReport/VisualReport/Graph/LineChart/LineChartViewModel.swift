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
    @Published var maxYValue: Int = 0
    @Published var minYValue: Int = 0
    @Published var chartYAxisValues: [Int] = []
    @Published var chartXAxisValues: [Date] = []
    @Published var chartOptions: [String] = []
    @Published var selectedChartOption: LineChartOption = .allYear
    @Published var viewModelData: LineChartViewModelData
    private var years: [String] = []
    
    init(lineChartViewModelData: LineChartViewModelData) {
        uiModels = []
        viewModelData = lineChartViewModelData
    }

    func createDataModel() {
        guard uiModels.isEmpty else {
            return
        }
        createUIModelForAllData(dataList: viewModelData.lineChartDataList)
        setInitialChartOptions()
    }
    
    func updateSelection(newSelection: String) {
        selectedChartOption = LineChartOption(value: newSelection)
        switch selectedChartOption {
            case .allYear:
                createUIModelForAllData(dataList: viewModelData.lineChartDataList)
            case .allMonthlyAverage:
                let monthlyAvgData = calculateMonthlyAverages(from: viewModelData.lineChartDataList)
                createUIModelForAllData(dataList: monthlyAvgData)
            case .last2Months:
                let last60Elements = Array(viewModelData.lineChartDataList.suffix(60))
                createUIModelForAllData(dataList: last60Elements)
            case .last2Weeks:
                let last14Elements = Array(viewModelData.lineChartDataList.suffix(14))
                createUIModelForAllData(dataList: last14Elements)
            case .year(let string):
                let yearData = filterData(forYear: string, from: viewModelData.lineChartDataList)
                createUIModelForAllData(dataList: yearData)
        }
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
    
    private func setInitialChartOptions() {
        // Set filter options
        guard let firstDate = viewModelData.lineChartDataList.first?.xTimeValue,
              let lastDate = viewModelData.lineChartDataList.last?.xTimeValue else {
            return
        }
        years = distinctYears(from: firstDate, to: lastDate)
        chartOptions = LineChartOption.allStaticCases
        for year in years {
            chartOptions.append(year)
        }
        selectedChartOption = .allYear
    }
    
    private func distinctYears(from firstDate: Date, to lastDate: Date) -> [String] {
        let calendar = Calendar.current
        var years: [String] = []
        
        var currentYear = calendar.component(.year, from: firstDate)
        let lastYear = calendar.component(.year, from: lastDate)
        
        while currentYear <= lastYear {
            years.append("\(currentYear)")
            currentYear += 1
        }
        return years
    }
    
    private func createUIModelForAllData(dataList: [LineChartDataModel]) {
        guard let firstDate = dataList.first?.xTimeValue,
              let lastDate = dataList.last?.xTimeValue else {
            return
        }
        uiFirstDate = firstDate
        uiLastDate = lastDate
        
        // RuleMark Data
        let ruleMarks = getRuleMarkList(
            chartDataPoints: dataList
        )
        
        // Chart Axis Data
        maxYValue = Int(dataList.map { $0.yValue }.max() ?? 0.0) + 20
        minYValue = Int(dataList.map { $0.yValue }.min() ?? 0.0) - 20
        if minYValue < 0 {
            minYValue = 0
        }
        chartYAxisValues = stride(from: minYValue, to: maxYValue, by: 10).map { $0 }
        chartXAxisValues.removeAll()
        var dayInterval = Int(dataList.count / 20)
        if dayInterval < 14 {
            dayInterval = 14
        }
        var dateFormat = "(yy-mm-dd)"
        if selectedChartOption.value == LineChartOption.last2Months.value {
            dayInterval = 5
            dateFormat = ""
        } else if selectedChartOption.value == LineChartOption.allMonthlyAverage.value {
            dayInterval = 32
        } else if selectedChartOption.value == LineChartOption.last2Weeks.value {
            dayInterval = 1
            dateFormat = ""
        }
        var currentDate = firstDate
        let calendar = Calendar.current
        while currentDate <= lastDate {
            chartXAxisValues.append(currentDate)
            if let nextDate = calendar.date(byAdding: .day, value: dayInterval, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        // UPDATE TIME FRAME
        
        viewModelData.timeFrame = "\(DateFormatter.dayMonthYearShort.string(from: firstDate)) to \(DateFormatter.dayMonthYearShort.string(from: lastDate))"
        
        // UPDATE UI DATA
        let uiModel = LineChartDataSeries(
            type: "\(selectedChartOption.value) \(dateFormat)",
            firstDate: firstDate,
            lastDate: lastDate,
            lineChartDataList: dataList,
            ruleMarkDataList: ruleMarks
        )
        uiModels = [uiModel]
    }
    
    private func filterData(forYear year: String, from allData: [LineChartDataModel]) -> [LineChartDataModel] {
        let calendar = Calendar.current
        // Convert the input year string to an integer
        guard let yearInt = Int(year) else {
            return [] // Return an empty list if the input year is not valid
        }
        // Filter the data where the xTimeValue year matches the input year
        let filteredData = allData.filter { data in
            let dataYear = calendar.component(.year, from: data.xTimeValue)
            return dataYear == yearInt
        }
        return filteredData
    }
    
    private func calculateMonthlyAverages(from allData: [LineChartDataModel]) -> [LineChartDataModel] {
        let calendar = Calendar.current
        // Group data by month and year
        let groupedData = Dictionary(grouping: allData) { data in
            calendar.date(from: calendar.dateComponents([.year, .month], from: data.xTimeValue))!
        }
        
        // Calculate monthly averages
        var monthlyAverageData: [LineChartDataModel] = []
        var index = 1
        for (date, dataList) in groupedData {
            let totalYValue = dataList.reduce(0) { $0 + $1.yValue }
            let averageYValue = totalYValue / Double(dataList.count)
            
            // Create a new LineChartDataModel with the average yValue
            let monthlyAverage = LineChartDataModel(id: index,
                                                    xTimeValue: date,
                                                    yValue: averageYValue)
            index += 1
            monthlyAverageData.append(monthlyAverage)
        }
        
        return monthlyAverageData.sorted { $0.xTimeValue < $1.xTimeValue }
    }
}

struct LineChartViewModelData {
    
    let chartName: String
    var timeFrame: String
    let weightUnitText: String
    let currencyUnitText: String
    let dataSource: String
    let lineChartDataList: [LineChartDataModel]
}

enum LineChartOption {
    
    case allYear, allMonthlyAverage, last2Months, last2Weeks
    case year(String)
    
    var value: String {
        switch self {
            case .allYear:
                "All Year"
            case .allMonthlyAverage:
                "All Monthly Average"
            case .last2Months:
                "Last 2 Months"
            case .last2Weeks:
                "Last 2 Weeks"
            case .year(let string):
                string
        }
    }
    
    static var allStaticCases: [String] {
        [
            LineChartOption.allYear.value,
            LineChartOption.allMonthlyAverage.value,
            LineChartOption.last2Months.value,
            LineChartOption.last2Weeks.value
        ]
    }
    
    init(value: String) {
        
        switch value {
            case LineChartOption.allYear.value:
                self = .allYear
            case LineChartOption.allMonthlyAverage.value:
                self = .allMonthlyAverage
            case LineChartOption.last2Months.value:
                self = .last2Months
            case LineChartOption.last2Weeks.value:
                self = .last2Weeks
            default:
                self = .year(value)
        }
    }
}
