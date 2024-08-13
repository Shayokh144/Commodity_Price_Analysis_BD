//
//  SingleBarViewModel.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 13/8/24.
//

import Foundation

final class SingleBarViewModel: ObservableObject {
    

    let productName: String
    let quantity: Double
    
    @Published private(set) var barChartData: [BarChartData] = []
    @Published private(set) var timeframe: String = ""
    @Published private(set) var quantityUnit: String = ""
    private let csvData: CSVDataModel
    
    init(csvData: CSVDataModel, productName: String, quantity: Double) {
        print("pr name: \(productName) qt: \(quantity)")
        self.csvData = csvData
        self.productName = productName
        self.quantity = quantity
        populateData()
    }
    
    private func populateData() {
        let rows = csvData.rows
        barChartData.removeAll()
        quantityUnit = ""
        for row in rows {
            let name = row["product_name"]
            let quantityValue = Double(row["weight_value"] ?? "0") ?? 0
            let price = Int(row["price"] ?? "0") ?? 0
            let dateStr = DateFormatter.dayMonthYear.date(from: row["date"] ?? "")
            if let date = dateStr, name == productName, quantity == quantityValue {
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

