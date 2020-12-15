//
//  NameSectionView.swift
//  Gravity
//
//  Created by Max Desiatov on 15/12/2020.
//

import SwiftUI

struct NameSectionView: View {
  let section: NameSection

  var body: some View {
    VStack {
      if let name = section.moduleName {
        Text(name)
          .font(.headline)
          .padding()
      }

      ScrollView {
        LazyVStack(alignment: .leading) {
          ForEach(
            section.functionNames.map { ($0, $1) }.sorted { $0.0 < $1.0 },
            id: \.0
          ) { idx, name in
            HStack {
              Text("\(idx)")
                .frame(width: 100)
              Text(name)
            }
          }
        }.padding()
      }
    }
  }
}
