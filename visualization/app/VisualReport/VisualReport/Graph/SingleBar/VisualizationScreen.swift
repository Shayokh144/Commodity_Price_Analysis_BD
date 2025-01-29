//
//  VisualizationScreen.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 13/8/24.
//

import SwiftUI

struct VisualizationScreen: View {
    
    @StateObject private var viewModel: VisualizationViewModel
    
    
    private var barChartView: some View {
        return BarChartView(viewModel: viewModel.barChartViewModel)
    }
    
    var body: some View {
        TabView {
            barChartView
                .navigationTitle("Single Bar")
                .tabItem { Text("Bar") }
            LineChartScreen(viewModel: viewModel.lineChartViewModel)
                .navigationTitle("Line chart")
                .tabItem { Text("Line Chart") }
            CompareTimeScreen(viewModel: viewModel.compareTimeViewModel)
                .navigationTitle("Compare Time")
                .tabItem { Text("Compare Time") }
        }
    }
    
    init(viewModel: VisualizationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}
