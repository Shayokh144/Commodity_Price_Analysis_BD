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
                AxisMarks(position: .trailing, values: viewModel.chartYAxisValues)
            }
            .chartXAxis{
                AxisMarks(position: .bottom, values: viewModel.chartXAxisValues) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel() {
                        if let date = value.as(Date.self) {
                            if viewModel.selectedChartOption.value == LineChartOption.last2Months.value ||
                                viewModel.selectedChartOption.value == LineChartOption.last2Weeks.value {
                                Text(DateFormatter.dayMonthYearShort.string(from: date))
                                    .rotationEffect(.degrees(-90))
                                    .padding(.bottom, 20.0)
                                    .padding(.leading, -16.0)
                            } else {
                                Text(DateFormatter.yearMontDayumber.string(from: date))
                                    .rotationEffect(.degrees(-90))
                                    .padding(.bottom, 20.0)
                                    .padding(.leading, -16.0)
                            }
                        }
                    }
                }
            }
            .chartYScale(domain: viewModel.minYValue...viewModel.maxYValue)
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
                Spacer()
                OptionPickerView(
                    optionList: viewModel.chartOptions,
                    selectedOption: .init(
                        get: {
                            viewModel.selectedChartOption.value
                        },
                        set: { newValue in
                            viewModel.updateSelection(newSelection: newValue)
                        }
                    )
                )
                .frame(maxWidth: 300.0)
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
