//
//  TypeSectionView.swift
//  Gravity
//
//  Created by Max Desiatov on 15/12/2020.
//

import SwiftUI
import WasmTransformer

enum FunctionOrder: String, CaseIterable, Identifiable, CustomStringConvertible {
  case appearance
  case numberOfParameters

  var id: String { rawValue }

  var description: String {
    switch self {
    case .appearance: return "appearance"
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
  @State private var orderSelection = FunctionOrder.appearance

  var body: some View {
    VStack {
      Picker("Order by", selection: $orderSelection) {
        ForEach(FunctionOrder.allCases) {
          Text($0.description).tag($0)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      .padding()

      ScrollView {
        LazyVStack(alignment: .leading) {
          ForEach(
            orderSelection == .appearance ?
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
