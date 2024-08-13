//
//  CSVFileReader.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 11/8/24.
//

import SwiftCSV
import Foundation

struct CSVFileReader {
    
    func readCSVFile(filePath: String) -> (CSVDataModel?, String?) {
        return readCSVData(filePath: filePath)
    }
    
    private func readCSVData(filePath: String) -> (CSVDataModel?, String?) {
        do {
            let csvFile: CSV = try CSV<Named>(url: URL(fileURLWithPath: filePath))
            var columns: [String]?
            if let keys = csvFile.columns?.keys {
                columns = Array(keys)
            }
            return (CSVDataModel(rows: csvFile.rows, columns: columns), nil)
        } catch {
            NSLog("ERROR: \(error)")
            return (nil, "No data found for file: \(filePath)")
        }
    }
}
