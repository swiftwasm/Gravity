//
//  GravityApp.swift
//  Shared
//
//  Created by Max Desiatov on 06/12/2020.
//

import SwiftUI

@main
struct GravityApp: App {
  var body: some Scene {
    DocumentGroup(viewing: WasmDocument.self) {
      ContentView(
        store: .init(
          initialState: .init(openedFile: $0.document),
          reducer: rootReducer,
          environment: rootEnvironment
        )
      )
    }
  }
}
