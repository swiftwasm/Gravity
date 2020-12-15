//
//  Created by Max Desiatov on 15/12/2020.
//

import SwiftUI
import WasmTransformer

struct RawSectionView: View {
  let input: InputByteStream
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
            Text(input.bytes[$0..<min($0 + symbols, section.endOffset)].hexEncodedString())
              .font(.system(size: 12, weight: .regular, design: .monospaced))
          }
        }.padding([.horizontal, .bottom])
      }
    }
  }
}
