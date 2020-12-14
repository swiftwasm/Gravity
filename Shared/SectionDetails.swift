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
  let input: InputByteStream
  let section: SectionInfo

  private let symbolWidth: CGFloat = 16

  var body: some View {
    GeometryReader { proxy in
      VStack {
        let symbols = proxy.size.width < symbolWidth ? 1 : Int(proxy.size.width / symbolWidth)
        if section.type == .custom, let name = { () -> String? in
          var input = self.input
          input.seek(section.endOffset - section.size)
          return input.readName()
        }() {
          Text("Custom section name: \(name)")
            .font(.headline)
            .padding()
        }

        ScrollView {
          LazyVStack(alignment: .leading) {
            ForEach(
              Array(stride(from: section.startOffset, to: section.endOffset, by: symbols)),
              id: \.self
            ) {
              Text(input.bytes[$0..<min($0 + symbols, section.endOffset)].hexEncodedString())
                .font(.system(size: 12, weight: .regular, design: .monospaced))
            }
          }.padding([.horizontal, .bottom])
        }
      }
    }
  }
}
