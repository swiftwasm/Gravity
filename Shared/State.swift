//
//  State.swift
//  Gravity
//
//  Created by Max Desiatov on 13/12/2020.
//

import ComposableArchitecture
import Combine

struct RootState: Equatable {
  var openedFile: WasmDocument?
  var isLoading = false

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
  case profilerResponse(Result<WasmDocument, Error>)
  case alert(AlertAction)
}

typealias RootStore = Store<RootState, RootAction>

struct RootEnvironment {
  let mainQueue: AnySchedulerOf<DispatchQueue>
  let openFile: () -> Effect<URL?, Never>
  let profile: (URL) -> Effect<WasmDocument, Error>
}

let rootReducer = Reducer<RootState, RootAction, RootEnvironment> { state, action, environment in
  switch action {
  case .openFile:
    return environment.openFile()
      .receive(on: environment.mainQueue)
      .map(RootAction.openFileResponse)
      .eraseToEffect()

  case let .openFileResponse(url?):
    state.isLoading = false
    return environment.profile(url)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(RootAction.profilerResponse)

  case .openFileResponse(nil):
    return .none

  case let .profilerResponse(.success(file)):
    state.openedFile = file
    state.isLoading = false
    return .none

  case let .profilerResponse(.failure(error)):
    state.alert = .init(error)
    state.isLoading = false
    return .none

  case .alert(.dismiss):
    state.alert = nil
    return .none
  }
}
