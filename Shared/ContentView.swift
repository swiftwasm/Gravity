//
//  ContentView.swift
//  Shared
//
//  Created by Max Desiatov on 06/12/2020.
//

import ComposableArchitecture
import SwiftUI

let measurementFormatter: MeasurementFormatter = {
  let result = MeasurementFormatter()
  result.unitStyle = .short
  result.unitOptions = [.naturalScale]
  return result
}()

struct ContentView: View {
  let store: RootStore

  var body: some View {
    HStack {
      Spacer()
      VStack {
        Spacer()
        WithViewStore(store) { viewStore in
          if let file = viewStore.openedFile {
            Text("\(file.filename), total size: \(file.totalSize, formatter: measurementFormatter)")
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
