//
//  BarChartView.swift
//  GraphComponent
//
//  Created by Taher on 25/1/24.
//

import SwiftUI

struct BarChartView: View {

    @StateObject var viewModel: BarChartViewModel
    
    private var barCharts: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .bottom,spacing: 8.0) {
                ForEach(viewModel.barChartUIModel) { uiModel in
                    VStack(alignment: .center, spacing: 1.0) {
                        Text("\(Int(uiModel.value))")
                            .font(.system(size: 12, weight: .bold))
                        Button {

                        } label: {
                            Rectangle()
                                .fill(Color.green.opacity(0.9))
                                .frame(width: 30.0, height: (uiModel.calculatedValue ?? 0.0) * 3)
                        }
                        .buttonStyle(.plain)
                        HStack(alignment: .bottom) {
                            Text(String(uiModel.name))
                                .foregroundStyle(Color.gray)
                                .fixedSize()
                                .frame(width: 30, height: 90)
                                .rotationEffect(.degrees(-90))

                        }
                    }
                }
            }
        }
    }
    
    private var barChartSection: some View {
        HStack {
            Text(viewModel.yAxisName)
                .foregroundStyle(Color.blue)
                .font(.system(size: 18.0, weight: .bold))
                .fixedSize()
                .frame(width: 30, height: 90)
                .rotationEffect(.degrees(-90))
                .padding(-8.0)
            barCharts
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray)
                }
        }
    }
    
    private var statSection: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack(spacing: 8.0) {
                Text(viewModel.minValueText)
                Spacer()
                Text(viewModel.maxValueText)
            }
            
            HStack {
                Text(viewModel.avgValueText)
                Spacer()
                Text(viewModel.dataCountText)
            }
            HStack {
                Text(viewModel.lastPrice)
                Spacer()
            }
        }
        .padding(.top, 16.0)
    }
    
    private var topSection: some View {
        VStack(alignment: .center, spacing: .zero) {
            Text(viewModel.chartName)
                .foregroundStyle(Color.purple)
                .font(.system(size: 32.0, weight: .bold))
                .padding(.bottom, 8.0)
            Text(viewModel.timeFrame)
                .font(.system(size: 18.0, weight: .bold))
                .padding(.bottom, 24.0)
            HStack {
                Text(viewModel.weightUnitText)
                Spacer()
                Text(viewModel.currencyUnitText)
                Spacer()
                Text(viewModel.dataSource)
            }
        }
        .padding(.bottom, 24.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            topSection
            barChartSection
            HStack {
                Spacer()
                Text(viewModel.xAxisName)
                    .foregroundStyle(Color.blue)
                    .font(.system(size: 18.0, weight: .bold))
                Spacer()
            }
            .padding(.top, 4.0)
            .padding(.bottom, 16.0)
            statSection
        }
        .padding()
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    init(viewModel: BarChartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

struct BarChartData: Identifiable {

    var id: String {
        UUID().uuidString
    }
    let name: String
    let value: Double
    let calculatedValue: Double?

    init(name: String, value: Double, calculatedValue: Double? = nil) {
        self.name = name
        self.value = value
        self.calculatedValue = calculatedValue
    }
}

extension BarChartData {

    static var dummyList: [BarChartData] {
        [
            .init(name: "January", value: 160),
            .init(name: "February", value: 140),
            .init(name: "March", value: 130),
            .init(name: "April", value: 180),
            .init(name: "May", value: 160),
            .init(name: "June", value: 190),
            .init(name: "July", value: 260),
            .init(name: "August", value: 460),
            .init(name: "September", value: 177),
            .init(name: "October", value: 199),
            .init(name: "November", value: 160),
            .init(name: "December", value: 80)
        ]
    }
}
