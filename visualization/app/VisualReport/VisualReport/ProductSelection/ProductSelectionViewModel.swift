//
//  ProductSelectionViewModel.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 11/8/24.
//

import Foundation

final class ProductSelectionViewModel: ObservableObject {
    
    struct ProductDetails: Hashable, Comparable {
        
        let name: String
        let quantity: String
        
        static func < (lhs: ProductDetails, rhs: ProductDetails) -> Bool {
            lhs.name < rhs.name
        }
    }
    
    private(set) var selectedQuantity: Double? = nil
    private(set) var selectedName: String = ""

    @Published private(set) var barChartData: [BarChartData] = []
    @Published private(set) var quantityUnit: String = ""
    @Published private(set) var productDetails: Set<ProductDetails> = []
    
    let csvData: CSVDataModel
    
    init(csvData: CSVDataModel) {
        self.csvData = csvData
        populateNameData()
    }
    
    func selectProduct(givenName: String, givenQuantity: String) -> Bool {
        let rows = csvData.rows
        for row in rows {
            if let productName = row["product_name"],
               let productQuantity = row["weight_raw"] {
                if productName.lowercased() == givenName.lowercased() && productQuantity == givenQuantity {
                    selectedName = productName
                    selectedQuantity = Double(row["weight_value"] ?? "0") ?? 0
                    return true
                }
            }
        }
        return false
    }
    
    private func populateNameData() {
        let rows = csvData.rows
        for row in rows {
            if let productName = row["product_name"] {
                let details = ProductDetails(
                    name: productName.lowercased(),
                    quantity: row["weight_raw"] ?? "0"
                )
                productDetails.insert(details)
            }
        }
    }
}

