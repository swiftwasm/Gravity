//
//  TypeSectionView.swift
//  Gravity
//
//  Created by Max Desiatov on 15/12/2020.
//

import SwiftUI
import WasmTransformer

struct TypeSectionView: View {
  enum OrderBy: String, CaseIterable, Identifiable, CustomStringConvertible {
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

  let signatures: [FuncSignature]
  @State private var orderSelection = OrderBy.appearance

  var body: some View {
    VStack {
      Picker("Order by", selection: $orderSelection) {
        ForEach(OrderBy.allCases) {
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
            let results = $0.results.count
            Text("\($0.params.count) parameters, \(results) result\(results != 1 ? "s" : "")")
              .padding(1)
          }
        }.padding()
      }
    }
  }
}
