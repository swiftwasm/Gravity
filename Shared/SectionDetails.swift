//
//  SectionDetails.swift
//  Gravity
//
//  Created by Max Desiatov on 14/12/2020.
//

import SwiftUI
import struct WasmTransformer.SectionInfo

extension Data {
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
  let fileData: Data
  let section: SectionInfo

  private let symbolWidth: CGFloat = 16

  var body: some View {
    GeometryReader { proxy in
      let symbols = proxy.size.width < symbolWidth ? 1 : Int(proxy.size.width / symbolWidth)
      ScrollView {
        LazyVStack(alignment: .leading) {
          ForEach(
            Array(stride(from: section.startOffset, to: section.endOffset, by: symbols)),
            id: \.self
          ) {
            Text(fileData[$0..<min($0 + symbols, section.endOffset)].hexEncodedString())
              .font(.system(size: 12, weight: .regular, design: .monospaced))
          }
        }.padding()
      }
    }
  }
}
