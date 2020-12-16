//
//  NameSection.swift
//  Gravity
//
//  Created by Max Desiatov on 15/12/2020.
//

import Darwin
import WasmTransformer

@_silgen_name("swift_demangle")
public func _stdlib_demangleImplementation(
  mangledName: UnsafePointer<CChar>?,
  mangledNameLength: UInt,
  outputBuffer: UnsafeMutablePointer<CChar>?,
  outputBufferSize: UnsafeMutablePointer<UInt>?,
  flags: UInt32
) -> UnsafeMutablePointer<CChar>?

func demangle(_ mangledName: String) -> String {
  mangledName.utf8CString.withUnsafeBufferPointer { mangledNameUTF8CStr in
    let demangledNamePtr = _stdlib_demangleImplementation(
      mangledName: mangledNameUTF8CStr.baseAddress,
      mangledNameLength: UInt(mangledNameUTF8CStr.count - 1),
      outputBuffer: nil,
      outputBufferSize: nil,
      flags: 0
    )

    if let demangledNamePtr = demangledNamePtr {
      let demangledName = String(cString: demangledNamePtr)
      free(demangledNamePtr)
      return demangledName
        .replacingOccurrences(of: " Swift.", with: " ")
        .replacingOccurrences(of: "(Swift.", with: "(")
        .replacingOccurrences(of: "<Swift.", with: "<")
    }
    return mangledName
  }
}

extension InputByteStream {
  /// https://webassembly.github.io/spec/core/binary/values.html#names
  mutating func readName() -> String? {
    let length = Int(readVarUInt32())
    let bytes = read(length)
    return String(bytes: bytes, encoding: .utf8)
  }
}

/// https://webassembly.github.io/spec/core/appendix/custom.html#name-section
struct NameSection: Equatable {
  enum Error: Swift.Error {
    case unknownSubsection(UInt8?)
  }

  private(set) var moduleName: String? = nil
  private(set) var functionNames = [Int: String]()

  init(_ input: inout InputByteStream, _ section: SectionInfo) throws {
    input.seek(section.endOffset - section.size)
    let name = input.readName()
    precondition(name == "name")

    while input.offset < section.endOffset {
      // https://webassembly.github.io/spec/core/appendix/custom.html#subsections
      let subsectionID = input.read(1).first
      _ = input.readVarUInt32()
      switch subsectionID {
      case 0:
        self.moduleName = input.readName()
      case 1:
        var functionNames = [Int: String]()
        let functionsCount = input.readVarUInt32()
        for _ in 0..<functionsCount {
          let idx = Int(input.readVarUInt32())
          let rawName = input.readName()
          functionNames[idx] = rawName.map(demangle)
        }
        self.functionNames = functionNames
      default:
        throw Error.unknownSubsection(subsectionID)
      }
    }
  }
}
