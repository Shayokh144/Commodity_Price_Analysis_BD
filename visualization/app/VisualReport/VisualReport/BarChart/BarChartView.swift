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
                        if viewModel.isInline {
                            ZStack(alignment: .bottom) {
                                barContent(height: uiModel.calculatedValue ?? 0.0)
                                barName(name: uiModel.name)
                            }
                        } else {
                            barContent(height: uiModel.calculatedValue ?? 0.0)
                            barName(name: uiModel.name)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
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
        }
        .padding()
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    init(viewModel: BarChartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private func barContent(height: Double) -> some View {
        Button {

        } label: {
            Rectangle()
                .fill(Color.green.opacity(0.9))
                .frame(width: 30.0, height: (height) * 2)
        }
        .buttonStyle(.borderless)
    }
    
    private func barName(name: String) -> some View {
        HStack(alignment: .bottom) {
            Text(String(name))
                .foregroundStyle(Color.blue)
                .fixedSize()
                .frame(width: 30, height: 90)
                .rotationEffect(.degrees(-90))
        }
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
            .init(name: "04-03-2023", value: 160),
            .init(name: "04-03-2023", value: 140),
            .init(name: "04-03-2023", value: 130),
            .init(name: "04-03-2023", value: 180),
            .init(name: "04-03-2023", value: 160),
            .init(name: "04-03-2023", value: 190),
            .init(name: "04-03-2023", value: 260),
            .init(name: "04-03-2023", value: 460),
            .init(name: "04-03-2023", value: 177),
            .init(name: "04-03-2023", value: 320),
            .init(name: "04-03-2023", value: 160),
            .init(name: "04-03-2023", value: 0)
        ]
    }
}
