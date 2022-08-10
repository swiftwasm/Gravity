//
//  FuncSectionView.swift
//  Gravity
//
//  Created by Max Desiatov on 16/12/2020.
//

import SwiftUI
import WasmTransformer

struct FuncSectionView: View {
  private struct Function: Identifiable {
    let id: Int
    let signature: FuncSignature
    let name: String
  }

  init(typeSection: TypeSection, funcSection: FuncSection, nameSection: NameSection) {
    functions = funcSection.typeIndices.enumerated().map {
      .init(
        id: $0,
        signature: typeSection.signatures[Int($1)],
        name: nameSection.functionNames[$0] ?? "\($0)"
      )
    }
  }

  private let functions: [Function]

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
        LazyVStack {
          ForEach(
            orderSelection == .index ?
              functions :
              functions.sorted { $0.signature.params.count > $1.signature.params.count }
          ) { f in
            HStack {
              Text(f.name).font(.headline)
              Spacer()
              Text(f.signature.description)
            }
            .padding(.horizontal)
            .padding(.vertical, 2)
          }
        }
      }
    }
  }
}
