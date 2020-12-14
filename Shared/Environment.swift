//
//  Environment.swift
//  Gravity
//
//  Created by Max Desiatov on 14/12/2020.
//

import AppKit
import Combine
import ComposableArchitecture
import Dispatch
import WasmTransformer

private let profilerQueue = DispatchQueue.global(qos: .userInitiated)

let rootEnvironment = RootEnvironment(
  mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
  openFile: {
    .future { promise in
      let openPanel = NSOpenPanel()
      openPanel.allowedFileTypes = ["wasm"]
      openPanel.canChooseFiles = true
      openPanel.begin { result in
        if result == .OK {
          if let url = openPanel.url {
            promise(.success(url))
          }
        } else if result == .cancel {
          promise(.success(nil))
        }
      }
    }
  },
  profile: { url in
    Just(url)
      .tryMap {
        var input = try InputByteStream(bytes: [UInt8](Data(contentsOf: $0)))
        return try .init(
          filename: url.lastPathComponent,
          totalSize: .init(value: Double(input.bytes.count), unit: .bytes),
          sections: input.readSectionsInfo(),
          input: input
        )
      }
      .subscribe(on: profilerQueue)
      .eraseToEffect()
  }
)
