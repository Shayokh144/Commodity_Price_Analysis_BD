//
//  CompareTimeScreen.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 9/12/24.
//

import SwiftUI
import Charts

struct CompareTimeScreen: View {
    
    @StateObject var viewModel: CompareTimeViewModel
    
    private var graph: some View {
        Chart(viewModel.compareTimeDataSeries, id: \.type) { dataSeries in
            ForEach(dataSeries.timeData) { data in
                LineMark(x: .value("Day", data.time),
                         y: .value("Price", data.value))
            }
            .foregroundStyle(by: .value("Time type", dataSeries.type))
        }
        .chartYAxis{
            AxisMarks(position: .trailing, values: viewModel.chartYAxisValues)
        }
        .chartYScale(domain: viewModel.minYValue...viewModel.maxYValue)
        .padding()
    }
    
    private var header: some View {
        HStack(alignment: .bottom) {
            Text("Product Name: \(viewModel.productName)")
                .font(.system(size: 24.0))
            Text("Quantity: \(viewModel.quantity)")
                .font(.system(size: 18.0))
                .foregroundColor(.green)
                .padding(.leading)
        }
    }
    
    private var filterOptions: some View {
        HStack(spacing: 24.0) {
            OptionPickerView(
                optionList: viewModel.startMonths,
                selectedOption: $viewModel.selectedStartMonth
            )
            Text("TO")
                .font(.system(size: 20.0))
                .padding(.horizontal)
            OptionPickerView(
                optionList: viewModel.endMonths,
                selectedOption: $viewModel.selectedEndMonth
            )
            Button(
                action: {
                    viewModel.filter()
                },
                label: {
                    Text("Update Data")
                        .font(.system(size: 16.0))
                        .padding(6.0)
                }
            )
            .buttonStyle(.bordered)
        }
    }
    
    var body: some View {
        VStack {
            header
                .padding()
            filterOptions
                .padding(.horizontal)
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            graph
        }
    }
    
    init (viewModel: CompareTimeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}
