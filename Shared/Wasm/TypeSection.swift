//
//  TypeSection.swift
//  Gravity
//
//  Created by Max Desiatov on 08/08/2022.
//

import WasmTransformer

struct TypeSection: Equatable {
  let signatures: [FuncSignature]
}
