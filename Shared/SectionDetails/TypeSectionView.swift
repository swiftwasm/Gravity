//
//  TypeSectionView.swift
//  Gravity
//
//  Created by Max Desiatov on 15/12/2020.
//

import SwiftUI
import WasmTransformer

enum FunctionsWithParametersOrder: String, CaseIterable, Identifiable, CustomStringConvertible {
  case index
  case numberOfParameters

  var id: String { rawValue }

  var description: String {
    switch self {
    case .index: return "index"
    case .numberOfParameters: return "number of parameters"
    }
  }
}

extension FuncSignature: CustomStringConvertible {
  public var description: String {
    "\(params.count) parameters, \(results.count) result\(results.count != 1 ? "s" : "")"
  }
}

struct TypeSectionView: View {
  let signatures: [FuncSignature]
  @State private var orderSelection = FunctionsWithParametersOrder.index

  var body: some View {
    VStack {
      Picker("Order by", selection: $orderSelection) {
        ForEach(FunctionsWithParametersOrder.allCases) {
          Text($0.description).tag($0)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      .padding([.horizontal, .bottom])

      ScrollView {
        LazyVStack(alignment: .leading) {
          ForEach(
            orderSelection == .index ?
              signatures : signatures.sorted { $0.params.count > $1.params.count },
            id: \.self
          ) {
            Text($0.description)
              .padding(.horizontal)
          }
        }.padding()
      }
    }
  }
}
