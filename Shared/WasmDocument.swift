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
  public static func == (lhs: InputByteStream, rhs: InputByteStream) -> Bool {
    lhs.bytes == rhs.bytes && lhs.offset == rhs.offset
  }
}

extension FuncSignature: Equatable {
  public static func == (lhs: FuncSignature, rhs: FuncSignature) -> Bool {
    lhs.params == rhs.params && lhs.results == rhs.results
  }
}

extension TypeSection: Equatable {
  public static func == (lhs: TypeSection, rhs: TypeSection) -> Bool {
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
    self.totalSize = .init(value: Double(data.count), unit: .bytes)
    self.input = .init(bytes: [UInt8](data))
    self.sections = try input.readSectionsInfo()
    guard let typeSection = sections.first(where: { $0.type == .type })
    else { throw Error.typeSectionAbsent }
    input.seek(typeSection.endOffset - typeSection.size)
    self.typeSection = try TypeSection(from: &input)
  }

  enum Error: Swift.Error {
    case readFailure
    case typeSectionAbsent
  }

  let filename: String
  let totalSize: Measurement<UnitInformationStorage>
  var input: InputByteStream
  let sections: [SectionInfo]
  let typeSection: TypeSection

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
