//
//  CodeSection.swift
//  Gravity (macOS)
//
//  Created by Max Desiatov on 10/08/2022.
//

import Foundation
import WasmTransformer

struct CodeSection: Equatable {
  struct Item: Identifiable, Equatable {
    let id: Int
    let name: String
    let body: FunctionBody

    var sizeMeasurement: Measurement<UnitInformationStorage> {
      .init(value: Double(body.size), unit: .bytes)
    }
  }

  let functions: [Item]
}
