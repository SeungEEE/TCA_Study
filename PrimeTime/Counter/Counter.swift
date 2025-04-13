//
//  Counter.swift
//  Counter
//
//  Created by 이승진 on 4/13/25.
//

public enum CounterAction {
    case decrTapped
    case incrTapped
}

public func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped:
        state -= 1
        
    case .incrTapped:
        state += 1
    }
}
