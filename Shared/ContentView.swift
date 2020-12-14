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
    WithViewStore(store) { viewStore in
      if let file = viewStore.openedFile {
        NavigationView {
          VStack {
            Text("Total size: \(file.totalSize, formatter: measurementFormatter)")
            List(file.sections, id: \.startOffset) { section in
              NavigationLink(destination: SectionDetails(fileData: file.data, section: section)) {
                SectionItem(section: section)
              }
            }
          }.frame(width: 200)
        }
      } else {
        HStack {
          Spacer()
          VStack {
            Spacer()
            Button("Open...") {
              viewStore.send(.openFile)
            }
            Spacer()
          }
          Spacer()
        }
      }
    }
  }
}
