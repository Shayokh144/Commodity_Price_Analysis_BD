//
//  SingleBarViewModel.swift
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

final class SingleBarViewModel: ObservableObject {
    
    @Published private(set) var barChartData: [BarChartData] = []
    @Published private(set) var timeframe: String = ""
    @Published private(set) var quantityUnit: String = ""
    
    let singleBarViewModelData: SingleBarViewModelData
    
    init(singleBarViewModelData: SingleBarViewModelData) {
        self.singleBarViewModelData = singleBarViewModelData
        populateData()
    }
    
    private func populateData() {
        let rows = singleBarViewModelData.csvData.rows
        barChartData.removeAll()
        quantityUnit = ""
        for row in rows {
            let name = row["product_name"]
            let quantityValue = Double(row["weight_value"] ?? "0") ?? 0
            let price = Int(row["price"] ?? "0") ?? 0
            let dateStr = DateFormatter.dayMonthYear.date(from: row["date"] ?? "")
            if let date = dateStr, name == singleBarViewModelData.productName, singleBarViewModelData.quantity == quantityValue {
                let dataName = DateFormatter.dayMonthYearShort.string(from: date)
                barChartData.append(BarChartData(name: dataName, value: Double(price)))
                if quantityUnit.isEmpty {
                    quantityUnit = row["weight_unit"] ?? ""
                }
            }
        }
        timeframe = "\(barChartData.first?.name ?? "") to \(barChartData.last?.name ?? "")"
    }
}

