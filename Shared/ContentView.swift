//
//  ContentView.swift
//  Shared
//
//  Created by Max Desiatov on 06/12/2020.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
  let store: RootStore

  var body: some View {
    HStack {
      Spacer()
      VStack {
        Spacer()
        WithViewStore(store) { viewStore in
          if let file = viewStore.openedFile {
            Text("\(file.url.lastPathComponent)")
            List(file.sections, id: \.startOffset) {
              SectionItem(section: $0)
            }
          } else {
            Button("Open...") {
              viewStore.send(.openFile)
            }
          }
        }
        Spacer()
      }
      Spacer()
    }
  }
}
