//
//  FuncSection.swift
//  Gravity
//
//  Created by Max Desiatov on 16/12/2020.
//

import WasmTransformer

/// https://webassembly.github.io/spec/core/binary/modules.html#function-section
struct FuncSection: Equatable {
  let typeIndices: [UInt32]
}
