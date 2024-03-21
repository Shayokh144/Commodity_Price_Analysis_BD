//
//  BarChartViewModel.swift
//  GraphComponent
//
//  Created by Taher on 25/1/24.
//

import Combine
import Foundation

final class BarChartViewModel: ObservableObject {

    @Published private(set) var barChartUIModel: [BarChartData]
    
    private let barChartData: [BarChartData]
    
    let minimumHeight: Double
    let xAxisName: String
    let yAxisName: String
    let isInline: Bool
    
    init(
        minimumHeight: Double = 40.0,
        xAxisName: String,
        yAxisName: String,
        isInline: Bool,
        barChartData: [BarChartData]
    ) {
        
        self.minimumHeight = minimumHeight
        self.xAxisName = xAxisName
        self.yAxisName = yAxisName
        self.isInline = isInline
        self.barChartData = barChartData
        barChartUIModel = []
    }

    func onAppear() {
        let maxValueLength = barChartData.map { $0.name.count }.max() ?? 0
        let minValue = barChartData
            .filter { $0.value != 0 }
            .map { $0.value }.min() ?? 1
        
        barChartUIModel = barChartData.map { barChartData in
            var paddedName = ""
            if isInline {
                paddedName = barChartData.name + String(repeating: " ", count: maxValueLength - barChartData.name.count + 1)
            } else {
                paddedName = String(repeating: " ", count: maxValueLength - barChartData.name.count + 1) + barChartData.name
            }
            let mappedValue = (minimumHeight /  minValue) * barChartData.value
            return BarChartData(
                name: paddedName,
                value: barChartData.value,
                calculatedValue: mappedValue
            )
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
