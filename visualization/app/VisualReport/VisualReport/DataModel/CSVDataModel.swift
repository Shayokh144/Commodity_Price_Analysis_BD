//
//  CSVDataModel.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 11/8/24.
//

import Foundation

struct CSVDataModel: Hashable {
    
    let rows: [[String : String]]
    let columns: [String]?
    
    init(rows: [[String : String]], columns: [String]?) {
        self.rows = rows
        self.columns = columns
    }
}
