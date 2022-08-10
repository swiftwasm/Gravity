//
//  Created by Max Desiatov on 15/12/2020.
//

import SwiftUI
import WasmTransformer

struct RawSectionView: View {
  let bytes: ArraySlice<UInt8>

  private let symbolWidth: CGFloat = 16

  var body: some View {
    GeometryReader { proxy in
      let symbols = proxy.size.width < symbolWidth ? 1 : Int(proxy.size.width / symbolWidth)

      ScrollView {
        LazyVStack(alignment: .leading) {
          ForEach(
            Array(stride(from: bytes.startIndex, to: bytes.endIndex, by: symbols)),
            id: \.self
          ) {
            Text(bytes[$0..<min($0 + symbols, bytes.endIndex)].hexEncodedString())
              .font(.system(size: 12, weight: .regular, design: .monospaced))
          }
        }.padding([.horizontal, .bottom])
      }
    }
  }
}
