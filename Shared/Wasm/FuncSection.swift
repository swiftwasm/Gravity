//
//  FuncSection.swift
//  Gravity
//
//  Created by Max Desiatov on 16/12/2020.
//

import WasmTransformer

/// https://webassembly.github.io/spec/core/binary/modules.html#function-section
struct FuncSection: Equatable {
  let typeIndices: [Int]

  init(_ input: inout InputByteStream) throws {
    let size = input.readVarUInt32()
    var typeIndices = [Int]()
    for _ in 0..<size {
      typeIndices.append(Int(input.readVarUInt32()))
    }
    self.typeIndices = typeIndices
  }
}
