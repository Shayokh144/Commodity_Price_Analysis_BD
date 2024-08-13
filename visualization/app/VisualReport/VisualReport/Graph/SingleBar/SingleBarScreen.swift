//
//  SingleBarScreen.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 13/8/24.
//

import SwiftUI

struct SingleBarScreen: View {
    
    @StateObject private var viewModel: SingleBarViewModel
    
    private var barChartView: some View {
        let barChartViewModel = BarChartViewModel(
            chartName: "Price chart for \(viewModel.productName)",
            timeFrame: viewModel.timeframe,
            weightUnitText: "Weight unit: \(viewModel.quantity) \(viewModel.quantityUnit)",
            currencyUnitText: "Currency unit: BDT(৳)",
            dataSource: "Data collected from ChalDal.com",
            xAxisName: "Timestamp",
            yAxisName: "Price",
            barChartData: viewModel.barChartData
        )
        return BarChartView(viewModel: barChartViewModel)
    }
    
    var body: some View {
        barChartView
    }
    
    init(viewModel: SingleBarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}
