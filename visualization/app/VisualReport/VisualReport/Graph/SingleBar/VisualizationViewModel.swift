//
//  VisualizationViewModel.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 13/8/24.
//

import Foundation

struct SingleBarViewModelData: Hashable {
    
    let csvData: CSVDataModel
    let productName: String
    let quantity: Double
}

final class VisualizationViewModel: ObservableObject {
    
    @Published private(set) var barChartData: [BarChartData] = []
    @Published private(set) var timeframe: String = ""
    @Published private(set) var quantityUnit: String = ""
    
    let singleBarViewModelData: SingleBarViewModelData
    private var lineChartDataModelList: [LineChartDataModel] = []
    
    init(singleBarViewModelData: SingleBarViewModelData) {
        self.singleBarViewModelData = singleBarViewModelData
        populateData()
    }
    
    var barChartViewModel: BarChartViewModel {
        BarChartViewModel(
            chartName: "Price chart for \(singleBarViewModelData.productName)",
            timeFrame: timeframe,
            weightUnitText: "Weight unit: \(singleBarViewModelData.quantity) \(quantityUnit)",
            currencyUnitText: "Currency unit: BDT(৳)",
            dataSource: "Data collected from ChalDal.com",
            xAxisName: "Timestamp",
            yAxisName: "Price",
            barChartData: barChartData
        )
    }
    
    var lineChartViewModel: LineChartViewModel {
        LineChartViewModel(
            lineChartViewModelData: LineChartViewModelData(
                chartName: "Price chart for \(singleBarViewModelData.productName)", 
                timeFrame: timeframe,
                weightUnitText: "Weight unit: \(singleBarViewModelData.quantity) \(quantityUnit)",
                currencyUnitText: "Currency unit: BDT(৳)",
                dataSource: "Data collected from ChalDal.com",
                lineChartDataList: lineChartDataModelList
            )
        )
    }
    
    private func populateData() {
        let rows = singleBarViewModelData.csvData.rows
        barChartData.removeAll()
        lineChartDataModelList.removeAll()
        quantityUnit = ""
        var index = 0
        for row in rows {
            let name = row["product_name"]
            let quantityValue = Double(row["weight_value"] ?? "0") ?? 0
            let price = Int(row["price"] ?? "0") ?? 0
            let dateStr = DateFormatter.dayMonthYear.date(from: row["date"] ?? "")
            if let date = dateStr, name == singleBarViewModelData.productName, singleBarViewModelData.quantity == quantityValue {
                let dataName = DateFormatter.dayMonthYearShort.string(from: date)
                barChartData.append(BarChartData(name: dataName, value: Double(price)))
                lineChartDataModelList.append(
                    .init(
                        id: index,
                        xTimeValue: date,
                        yValue: Double(price)
                    )
                )
                index += 1
                if quantityUnit.isEmpty {
                    quantityUnit = row["weight_unit"] ?? ""
                }
            }
        }
        timeframe = "\(barChartData.first?.name ?? "") to \(barChartData.last?.name ?? "")"
    }
}

