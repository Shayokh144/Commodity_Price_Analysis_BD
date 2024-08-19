//
//  Double+Extension.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 19/8/24.
//

extension Double {
    
    var fractionTwoDigitString:String {
        return String(format: "%.2f", self)
    }
    
    var fractionOneDigitString:String {
        return String(format: "%.1f", self)
    }
}
