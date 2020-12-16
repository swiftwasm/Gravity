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

  private func customSectionName(_ section: SectionInfo) -> String? {
    var input = file.input
    input.seek(section.endOffset - section.size)
    return input.readName()
  }

  var body: some View {
    let section = file.sections[sectionID]
    let name = customSectionName(section)
    VStack {
      if section.type == .custom, let name = name {
        Text("Custom section name: \(name)")
          .font(.headline)
          .padding()
      }

      switch section.type {
      case .type:
        TypeSectionView(signatures: file.typeSection.signatures)
      case .function:
        if let nameSection = file.nameSection {
          FuncSectionView(
            typeSection: file.typeSection,
            funcSection: file.funcSection,
            nameSection: nameSection
          )
        } else {
          RawSectionView(input: file.input, section: section)
        }
      case .custom where name == "name":
        if let nameSection = file.nameSection {
          NameSectionView(section: nameSection)
        } else {
          RawSectionView(input: file.input, section: section)
        }
      default:
        RawSectionView(input: file.input, section: section)
      }
    }
  }
}
