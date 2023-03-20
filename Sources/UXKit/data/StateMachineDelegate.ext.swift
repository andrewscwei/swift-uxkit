// © GHOZT

import BaseKit
import UIKit

extension StateMachineDelegate where Self: UIViewController {

  public func observe<T: Equatable>(_ liveData: LiveData<T>, invalidate keyPath: AnyKeyPath) {
    liveData.observe(for: self) { _ in
      DispatchQueue.main.async {
        self.stateMachine.invalidate(keyPath)
      }
    }
  }

  public func observe<T: Equatable>(_ liveData: LiveData<T>, invalidate stateType: StateType) {
    liveData.observe(for: self) { _ in
      DispatchQueue.main.async {
        self.stateMachine.invalidate(stateType)
      }
    }
  }

  public func unobserve<T: Equatable>(_ liveData: LiveData<T>) {
    liveData.unobserve(for: self)
  }
}