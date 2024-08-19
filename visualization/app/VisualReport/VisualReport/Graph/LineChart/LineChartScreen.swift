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
                        .annotation(position: .bottom,
                                    alignment: .bottomLeading) {
                            Text("\(data.ruleMarkName): \(data.yValue.fractionTwoDigitString)")
                                .foregroundColor(.orange)
                        }
                }
            }
            .chartXScale(
                domain: firstDate...lastDate
            )
            .aspectRatio(1, contentMode: .fit)
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

//struct LineChartScreen: View {
//
//    var newData = [PetDataModel]()
//
//    var data: [PetDataSeries] {
//        [PetDataSeries(type: "ABC", petData: newData)]
//    }
//    
//    let firstDate: Date
//    let lastDate: Date
//    var body: some View {
//        Chart(data, id: \.type) { dataSeries in
//            ForEach(dataSeries.petData) { data in
//                LineMark(x: .value("Year", data.year, unit: .day),
//                         y: .value("Population", data.population))
//            }
//            .foregroundStyle(by: .value("Pet type", dataSeries.type))
//            .symbol(by: .value("Pet type", dataSeries.type))
//            RuleMark(y: .value("Average 1", 1.5))
//                .annotation(position: .bottom,
//                            alignment: .bottomLeading) {
//                    Text("average 1.5")
//                        .foregroundColor(.orange)
//                }
//            RuleMark(y: .value("Average 2", 2.5))
//                .annotation(position: .bottom,
//                            alignment: .bottomLeading) {
//                    Text("average 2.5")
//                        .foregroundColor(.orange)
//                }
//        }
//        .chartXScale(domain: firstDate...lastDate)
//        .aspectRatio(1, contentMode: .fit)
//        .padding()
//    }
//    
//    init() {
//        for i in 0 ..< 10 {
//            let date = Calendar.current.date(byAdding: .day, value: i, to: .now) ?? .now
//            let rep = Double.random(in: 10...100)
//            newData.append(
//                .init(year: date, population: rep)
//            )
//        }
//        firstDate = newData[0].year
//        lastDate = newData[9].year
//    }
//}
//
//struct PetDataSeries: Identifiable {
//    let type: String
//    let petData: [PetDataModel]
//    var id: String { type }
//}
//
//
//struct PetDataModel: Identifiable {
//    
//    let id = UUID()
//    let year: Date
//    let population: Double
//}
