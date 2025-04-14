//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by 이승진 on 4/13/25.
//

import ComposableArchitecture
import SwiftUI

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

public struct FavoritePrimesView: View {
    @ObservedObject var store: Store<[Int], FavoritePrimesAction>
    
    public init(store: Store<[Int], FavoritePrimesAction>) {
        self.store = store
    }
    
    public var body: some View {
        List {
            ForEach(self.store.value, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                self.store.send(.deleteFavoritePrimes(indexSet))
//                self.store.send(.counter(.incrTapped))
            }
        }
        .navigationBarTitle("Favorite Primes")
    }
}


