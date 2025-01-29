//
//  DateFormatter+Extension.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 11/8/24.
//

import Foundation

extension DateFormatter {

    public static let dayMonthYear: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter
    }()
    
    public static let dayMonth: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "dd-MM"
        return dateFormatter
    }()
    
    public static let dayMonthYearShort: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "dd-MMM-yy"
        return dateFormatter
    }()

    public static let monthYear: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyy-MM"
        return dateFormatter
    }()
    
    public static let monthYearShort: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yy-MM"
        return dateFormatter
    }()
    
    public static let yearMontDayumber: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yy-MM-dd"
        return dateFormatter
    }()
}
