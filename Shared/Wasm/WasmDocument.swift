//
//  WasmDocument.swift
//  Gravity
//
//  Created by Max Desiatov on 14/12/2020.
//

import SwiftUI
import UniformTypeIdentifiers
import WasmTransformer

extension UTType {
  static var wasm: UTType {
    UTType(importedAs: "public.wasm")
  }
}

extension InputByteStream: Equatable {
  public static func ==(lhs: InputByteStream, rhs: InputByteStream) -> Bool {
    lhs.bytes == rhs.bytes && lhs.offset == rhs.offset
  }
}

extension FuncSignature: Equatable {
  public static func ==(lhs: FuncSignature, rhs: FuncSignature) -> Bool {
    lhs.params == rhs.params && lhs.results == rhs.results
  }
}

extension TypeSection: Equatable {
  public static func ==(lhs: TypeSection, rhs: TypeSection) -> Bool {
    lhs.signatures == rhs.signatures
  }
}

extension FuncSignature: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(params)
    hasher.combine(results)
  }
}

struct WasmDocument: FileDocument, Equatable {
  init(
    filename: String,
    data: Data
  ) throws {
    self.filename = filename
    totalSize = .init(value: Double(data.count), unit: .bytes)
    input = .init(bytes: [UInt8](data))
    sections = try input.readSectionsInfo()
    input.seek(8)

    var moduleReader = ModuleReader(input: input)

    var maybeTypeSection: TypeSection?
    var maybeFuncSection: FuncSection?

    var sectionIndex = 0
    while !moduleReader.isEOF {
      defer {
        sectionIndex += 1
      }

      switch try moduleReader.readSection() {
      case .type(let reader):
       maybeTypeSection = try TypeSection(signatures: reader.collect())

      case .rawSection(type: .custom, content: let content):
        var input = InputByteStream(bytes: content)

        if let name = input.readName(), name == "name" {
          input.seek(sections[sectionIndex].contentStart)
          nameSection = try NameSection(&input)
        }

      case .function(let reader):
        maybeFuncSection = try FuncSection(typeIndices: reader.collect().map(\.value))

      default:
        continue
      }
    }

    guard let typeSection = maybeTypeSection
    else { throw Error.requiredSectionAbsent(.type) }
    guard let funcSection = maybeFuncSection
    else { throw Error.requiredSectionAbsent(.function) }
    self.typeSection = typeSection
    self.funcSection = funcSection
  }

  enum Error: Swift.Error {
    case readFailure
    case requiredSectionAbsent(SectionType)
  }

  let filename: String
  let totalSize: Measurement<UnitInformationStorage>
  var input: InputByteStream
  let sections: [SectionInfo]
  let typeSection: TypeSection
  let funcSection: FuncSection
  private(set) var nameSection: NameSection?

  static let readableContentTypes = [UTType.wasm]

  init(configuration: ReadConfiguration) throws {
    guard
      configuration.contentType.identifier == UTType.wasm.identifier,
      let filename = configuration.file.filename,
      let data = configuration.file.regularFileContents
    else {
      throw Error.readFailure
    }

    try self.init(filename: filename, data: data)
  }

  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    .init(regularFileWithContents: Data(input.bytes))
  }
}
