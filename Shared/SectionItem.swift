//
//  SectionItem.swift
//  Gravity
//
//  Created by Max Desiatov on 14/12/2020.
//

import Foundation
import WasmTransformer
import SwiftUI

private let formatter: MeasurementFormatter = {
  let result = MeasurementFormatter()
  result.unitStyle = .short
  result.unitOptions = [.naturalScale]
  return result
}()

extension SectionType: CustomStringConvertible {
  public var description: String {
    switch self {
    case .code: return "code"
    case .custom: return "custom"
    case .data: return "data"
    case .dataCount: return "dataCount"
    case .elem: return "elem"
    case .export: return "export"
    case .function: return "function"
    case .global: return "global"
    case .import: return "import"
    case .type: return "type"
    case .table: return "table"
    case .memory: return "memory"
    case .start: return "start"
    }
  }
}

extension SectionInfo {
  var sizeMeasurement: Measurement<UnitInformationStorage> {
    .init(value: Double(size), unit: .bytes)
  }
}

struct SectionItem: View {
  let section: SectionInfo

  var body: some View {
    Text("\(section.type.description): \(section.sizeMeasurement, formatter: formatter)")
  }
}
