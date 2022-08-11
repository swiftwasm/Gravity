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

extension SectionInfo {
  public func description(customSectionName: String?) -> String {
    switch type {
    case .custom:
      if let name = customSectionName {
        return "Custom section named: `\(name)`"
      } else {
        return "Unnamed custom section"
      }

    case .type:
      return "Types section"

    case .function:
      return "Functions to types mapping section"

    case .code:
      return "Code section"

    case .global:
      return "Globals section"

    case .import:
      return "Imports section"

    case .export:
      return "Exports section"

    case .data:
      return "Data segments section"

    default:
      return "Unknown section"
    }
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
    VStack {
      let name = customSectionName(section)
      Text(try! AttributedString(markdown: section.description(customSectionName: name)))
        .font(.headline)
        .padding()

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
          RawSectionView(bytes: file.input.bytes[section.startOffset..<section.endOffset])
        }
      case .custom where name == "name":
        if let nameSection = file.nameSection {
          NameSectionView(section: nameSection)
        } else {
          RawSectionView(bytes: file.input.bytes[section.startOffset..<section.endOffset])
        }
      case .code:
        if file.nameSection != nil {
          CodeSectionView(codeSection: file.codeSection)
        } else {
          RawSectionView(bytes: file.input.bytes[section.startOffset..<section.endOffset])
        }
      default:
        RawSectionView(bytes: file.input.bytes[section.startOffset..<section.endOffset])
      }
    }
  }
}
