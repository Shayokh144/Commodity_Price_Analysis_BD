//
//  OptionPickerView.swift
//  VisualReport
//
//  Created by Taher's nimble macbook on 20/8/24.
//

import SwiftUI

struct OptionPickerView: View {

    private let optionList: [String]
    @Binding private var selectedOption: String

    var body: some View {
        HStack(spacing: .zero) {
            Spacer()
            Picker("", selection: $selectedOption) {
                ForEach(optionList, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)
            .clipped()
            .labelsHidden()
            .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                    .stroke(
                        Color.purple,
                        lineWidth: 1.0
                    )
            )
        }
    }

    init(optionList: [String], selectedOption: Binding<String>) {
        self.optionList = optionList
        _selectedOption = selectedOption
    }
}
