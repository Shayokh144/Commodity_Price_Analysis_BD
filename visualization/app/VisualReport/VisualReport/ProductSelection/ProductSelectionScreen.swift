//
//  ProductSelectionScreen.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 11/8/24.
//

import SwiftUI

struct ProductSelectionScreen: View {
    
    @StateObject private var viewModel: ProductSelectionViewModel
    @State private var showDetails = false
    
    private var nameView: some View {
        ScrollView(.vertical) {
            ForEach(viewModel.productDetails.sorted(by: <), id: \.self) { data in
                Button(
                    action: {
                        showDetails = viewModel.selectProduct(givenName: data.name)
                    },
                    label: {
                        HStack(spacing: 16.0) {
                            Text(data.name)
                                .font(.system(size: 16.0, weight: .bold))
                            Text(data.quantity)
                                .font(.system(size: 12.0, weight: .regular))
                        }
                        .padding(8.0)
                    }
                )
                .buttonStyle(.bordered)
            }
        }
    }
    
    private var detailsView: some View {
        SingleBarScreen(
            viewModel: SingleBarViewModel(
                csvData: viewModel.csvData,
                productName: viewModel.selectedName,
                quantity: viewModel.selectedQuantity ?? 0.0
            )
        )
    }
    
    private var backButton: some View {
        HStack {
            Button(
                action: {
                    showDetails.toggle()
                },
                label: {
                    Text("< Back")
                        .font(.system(size: 16.0))
                }
            )
            Spacer()
        }
        .padding([.top, .leading])
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if showDetails {
                backButton
                detailsView
            }
            nameView
                .opacity(showDetails ? 0.0 : 1.0 )
        }
        .padding()
    }
    
    init(viewModel: ProductSelectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

