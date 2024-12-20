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
        }
    }
    
    init(viewModel: SingleBarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}
