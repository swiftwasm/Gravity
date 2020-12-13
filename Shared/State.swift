//
//  State.swift
//  Gravity
//
//  Created by Max Desiatov on 13/12/2020.
//

import struct WasmTransformer.SectionInfo
import ComposableArchitecture
import Combine

struct RootState: Equatable {
  var sections: [SectionInfo]?

  var alert: AlertState<AlertAction>?
}

extension AlertState {
  init(_ error: Error) {
    self.init(
      title: .init((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
    )
  }
}

enum AlertAction {
  case dismiss
}

enum RootAction {
  case openFile
  case openFileResponse(URL?)
  case profilerResponse(Result<[SectionInfo], Error>)
  case alert(AlertAction)
}

struct RootEnvironment {
  let mainQueue: AnySchedulerOf<DispatchQueue>
  let openFile: () -> Effect<URL?, Never>
  let profile: (URL) -> Effect<[SectionInfo], Error>
}

let rootReducer = Reducer<RootState, RootAction, RootEnvironment> { state, action, environment in
  switch action {
  case .openFile:
    return environment.openFile()
      .receive(on: environment.mainQueue)
      .map(RootAction.openFileResponse)
      .eraseToEffect()

  case let .openFileResponse(url?):
    return environment.profile(url)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(RootAction.profilerResponse)

  case let .profilerResponse(.success(sections)):
    state.sections = sections
    return .none

  case .openFileResponse(nil):
    return .none

  case let .profilerResponse(.failure(error)):
    state.alert = .init(error)
    return .none

  case .alert(.dismiss):
    state.alert = nil
    return .none
  }
}
