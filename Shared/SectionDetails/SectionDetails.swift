//
//  SectionDetails.swift
//  Gravity
//
//  Created by Max Desiatov on 14/12/2020.
//

import SwiftUI
import WasmTransformer

extension ArraySlice where Element == UInt8 {
  struct HexEncodingOptions: OptionSet {
    let rawValue: Int
    static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
  }

  func hexEncodedString(options: HexEncodingOptions = []) -> String {
    let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
    return map { String(format: format, $0) }.joined()
  }
}

struct SectionDetails: View {
  let file: WasmDocument
  let sectionID: Int

  var body: some View {
    let section = file.sections[sectionID]
    VStack {
      if section.type == .custom, let name = { () -> String? in
        var input = file.input
        input.seek(section.endOffset - section.size)
        return input.readName()
      }() {
        Text("Custom section name: \(name)")
          .font(.headline)
          .padding()
      }

      switch section.type {
      case .type:
        TypeSectionView(signatures: file.typeSection.signatures)
      default:
        RawSectionView(input: file.input, section: section)
      }
    }
  }
}
