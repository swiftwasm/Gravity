//
//  DWARF.swift
//  Gravity
//
//  Created by Max Desiatov on 14/12/2020.
//

import Foundation
import WasmTransformer

extension InputByteStream {
  /// https://webassembly.github.io/spec/core/binary/values.html#names
  mutating func readName() -> String? {
    let length = Int(readVarUInt32())
    let bytes = read(length)
    return String(bytes: bytes, encoding: .utf8)
  }
}
