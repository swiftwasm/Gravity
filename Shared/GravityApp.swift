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
    WindowGroup {
      ContentView(
        store: .init(initialState: .init(), reducer: rootReducer, environment: rootEnvironment)
      )
    }
  }
}
