//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by 이승진 on 4/13/25.
//


public enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
    
//    var deleteFavoritePrimes: IndexSet? {
//        get {
//            guard case let .deleteFavoritePrimes(value) = self else { return nil }
//            return value
//        }
//        set {
//            guard case .deleteFavoritePrimes = self, let newValue = newValue else { return }
//            self = .deleteFavoritePrimes(newValue)
//        }
//    }
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
    }
}


