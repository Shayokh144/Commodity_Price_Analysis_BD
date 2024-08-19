//
//  LineChartScreen.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 16/8/24.
//

import Charts
import SwiftUI

struct LineChartScreen: View {
    @StateObject private var viewModel: LineChartViewModel
    
    @ViewBuilder private var chartView: some View {
        if let firstDate = viewModel.uiFirstDate,
           let lastDate = viewModel.uiLastDate {
            Chart($viewModel.uiModels) { $dataSeries in
                ForEach($dataSeries.lineChartDataList) { $data in
                    LineMark(x: .value("Date", data.xTimeValue, unit: .day),
                             y: .value("Price", data.yValue))
                }
                .foregroundStyle(by: .value("Chart type", dataSeries.type))
                ForEach($dataSeries.ruleMarkDataList) { $data in
                    RuleMark(y: .value(data.yName, data.yValue))
                        .foregroundStyle(Color.orange)
                        .lineStyle(StrokeStyle(lineWidth: 1))
                        .annotation(position: .bottom,
                                    alignment: .bottomLeading) {
                            Text("\(data.ruleMarkName): \(data.yValue.fractionTwoDigitString)")
                                .foregroundColor(.orange)
                        }
                }
            }
            .chartYAxis{
                AxisMarks(position: .leading, values: viewModel.chartYAxisValues)
            }
            .chartXAxis{
                AxisMarks(position: .bottom, values: viewModel.chartXAxisValues) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel() {
                        if let date = value.as(Date.self) {
                            Text(DateFormatter.monthYearShort.string(from: date))
                        }
                    }
                }
            }
            .chartXScale(
                domain: firstDate...lastDate
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var topSection: some View {
        VStack(alignment: .center, spacing: .zero) {
            Text(viewModel.viewModelData.chartName)
                .foregroundStyle(Color.purple)
                .font(.system(size: 32.0, weight: .bold))
                .padding(.bottom, 8.0)
            Text(viewModel.viewModelData.timeFrame)
                .foregroundStyle(Color.green)
                .font(.system(size: 22.0, weight: .bold))
                .padding(.bottom, 24.0)
            HStack {
                Text(viewModel.viewModelData.weightUnitText)
                Spacer()
                Text(viewModel.viewModelData.currencyUnitText)
                Spacer()
                Text(viewModel.viewModelData.dataSource)
            }
            .font(.system(size: 14.0, weight: .bold))
            .foregroundStyle(Color.purple)
        }
        .padding(.bottom, 24.0)
    }
    
    var body: some View {
        VStack {
            topSection
            chartView
        }
        .padding()
        .onAppear {
            viewModel.createDataModel()
        }
    }
    
    init(viewModel: LineChartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}
