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

struct WasmDocument: FileDocument, Equatable {
  init(
    filename: String,
    totalSize: Measurement<UnitInformationStorage>,
    sections: [SectionInfo],
    data: Data
  ) {
    self.filename = filename
    self.totalSize = totalSize
    self.sections = sections
    self.data = data
  }

  enum Error: Swift.Error {
    case readFailure
  }

  let filename: String
  let totalSize: Measurement<UnitInformationStorage>
  let sections: [SectionInfo]
  let data: Data

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
    self.data = data
    totalSize = .init(value: Double(data.count), unit: .bytes)
    sections = try sizeProfiler(.init(data))
  }

  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    .init(regularFileWithContents: data)
  }
}
