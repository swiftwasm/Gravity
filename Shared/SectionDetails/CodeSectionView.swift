//
//  CodeSectionView.swift
//  Gravity (macOS)
//
//  Created by Max Desiatov on 10/08/2022.
//

import SwiftUI
import WasmTransformer

private enum FunctionOrder: String, CaseIterable, Identifiable, CustomStringConvertible {
  case index
  case size

  var id: String { rawValue }

  var description: String {
    rawValue
  }
}

struct CodeSectionView: View {
  let codeSection: CodeSection
  
  @State private var orderSelection = FunctionOrder.index

  @ScaledMetric var functionSizeTextWidth = 80

  var body: some View {
    VStack {
      Picker("Order by", selection: $orderSelection) {
        ForEach(FunctionOrder.allCases) {
          Text($0.description).tag($0)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      .padding([.horizontal, .bottom])

      ScrollView {
        LazyVStack(alignment: .leading) {
          ForEach(
            orderSelection == .index ?
            codeSection.functions : codeSection.functions.sorted { $0.body.size > $1.body.size }
          ) { item in
            HStack {
              Text("\(item.sizeMeasurement, formatter: measurementFormatter)")
                .frame(width: functionSizeTextWidth, alignment: .trailing)
              Text(item.name)
                .font(
                  .body
                  .monospaced()
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 3)
          }
        }.padding()
      }
    }
  }
}
