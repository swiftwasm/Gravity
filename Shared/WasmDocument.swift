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

struct WasmDocument: FileDocument, Equatable {
  init(
    filename: String,
    totalSize: Measurement<UnitInformationStorage>,
    sections: [SectionInfo],
    input: InputByteStream
  ) {
    self.filename = filename
    self.totalSize = totalSize
    self.sections = sections
    self.input = input
  }

  enum Error: Swift.Error {
    case readFailure
  }

  let filename: String
  let totalSize: Measurement<UnitInformationStorage>
  let sections: [SectionInfo]
  var input: InputByteStream

  static let readableContentTypes = [UTType.wasm]

  init(configuration: ReadConfiguration) throws {
    guard
      configuration.contentType.identifier == UTType.wasm.identifier,
      let filename = configuration.file.filename,
      let data = configuration.file.regularFileContents
    else {
      throw Error.readFailure
    }

    self.filename = filename
    self.input = .init(bytes: [UInt8](data))
    totalSize = .init(value: Double(data.count), unit: .bytes)
    sections = try input.readSectionsInfo()
  }

  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    .init(regularFileWithContents: Data(input.bytes))
  }
}
