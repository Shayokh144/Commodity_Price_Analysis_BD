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
    @Binding private var navigationPath: NavigationPath
    
    private var nameView: some View {
        ScrollView(.vertical) {
            ForEach(viewModel.productDetails.sorted(by: <), id: \.self) { data in
                Button(
                    action: {
                        showDetails = viewModel.selectProduct(givenName: data.name)
                        if showDetails {
                            navigationPath.append(
                                SingleBarViewModelData(
                                    csvData: viewModel.csvData,
                                    productName: viewModel.selectedName, 
                                    quantity: viewModel.selectedQuantity ?? 0.0
                                )
                            )
                        }
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
    
    var body: some View {
        VStack(alignment: .leading) {
            nameView
        }
        .navigationTitle("Select Product")
        .padding()
    }
    
    init(viewModel: ProductSelectionViewModel, navigationPath: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _navigationPath = navigationPath
    }
}
