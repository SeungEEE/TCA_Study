//
//  ContentView.swift
//  PrimeTime
//
//  Created by 이승진 on 4/13/25.
//

import Combine
import SwiftUI
import ComposableArchitecture
import FavoritePrimes
import Counter
import PrimeModal


struct AppState {
    var count = 0
    var favoritePrimes: [Int] = []
//    var primeModal: PrimeModalState
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []
    
    struct Activity {
        let timestamp: Date
        let type: ActivityType
        
        enum ActivityType {
            case addedFavoritePrime(Int)
            case removedFavoritePrime(Int)
            
            var addedFavoritePrime: Int? {
                get {
                    guard case let .addedFavoritePrime(value) = self else { return nil }
                    return value
                }
                set {
                    guard case .addedFavoritePrime = self, let newValue = newValue else { return }
                    self = .addedFavoritePrime(newValue)
                }
            }
            
            var removedFavoritePrime: Int? {
                get {
                    guard case let .removedFavoritePrime(value) = self else { return nil }
                    return value
                }
                set {
                    guard case .removedFavoritePrime = self, let newValue = newValue else { return }
                    self = .removedFavoritePrime(newValue)
                }
            }
        }
    }
    
    struct User {
        let id: Int
        let name: String
        let bio: String
    }
}

enum AppAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    case favoritePrimes(FavoritePrimesAction)
    
    var counter: CounterAction? {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }
    
    var primeModal: PrimeModalAction? {
        get {
            guard case let .primeModal(value) = self else { return nil }
            return value
        }
        set {
            guard case .primeModal = self, let newValue = newValue else { return }
            self = .primeModal(newValue)
        }
    }
    
    var favoritePrimes: FavoritePrimesAction? {
        get {
            guard case let .favoritePrimes(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritePrimes = self, let newValue = newValue else { return }
            self = .favoritePrimes(newValue)
        }
    }
}

let someAction = AppAction.counter(.incrTapped)

struct _KeyPath<Root, Value> {
    let get: (Root) -> Value
    let set: (inout Root, Value) -> Void
}


let action = AppAction.favoritePrimes(.deleteFavoritePrimes([1]))
//let favoritePrimes: FavoritePrimesAction?

//switch action {
//case let .favoritePrimes(action):
//    favoritePrimes = action
//default:
//    favoritePrimes = nil
//}

struct EnumKeyPath<Root, Value> {
    let embed: (Value) -> Root
    let extract: (Root) -> Value?
}

func activityFeed(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    
    return { state, action in
        switch action {
        case .counter:
            break
        case .primeModal(.removeFavoritePrimeTapped):
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
            
        case .primeModal(.saveFavoritePrimeTapped):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
            
        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.favoritePrimes[index])))
            }
        }
        
        reducer(&state, action)
    }
}

extension AppState {
    var primeModal: PrimeModalState {
        get {
            PrimeModalState(
                count: self.count,
                favoritePrimes: self.favoritePrimes
            )
        }
        
        set {
            self.count = newValue.count
            self.favoritePrimes = newValue.favoritePrimes
        }
    }
}

let _appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(counterReducer, value: \.count, action: \.counter),
    pullback(primeModalReducer, value: \.primeModal, action: \.primeModal),
    pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)

let appReducer = pullback(_appReducer, value: \.self, action: \.self)

var state = AppState()

struct PrimeAlert: Identifiable {
    let prime: Int
    var id: Int { self.prime }
}

struct CounterView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @State var isPrimeModalShown = false
    @State var alertNthPrime: PrimeAlert?
    @State var isNthPrimeButtonDisabled = false
    
    var body: some View {
        VStack {
            HStack {
                Button("-") { self.store.send(.counter(.decrTapped)) }
                Text("\(self.store.value.count)")
                Button("+") { self.store.send(.counter(.incrTapped)) }
            }
            Button("Is this prime?") { self.isPrimeModalShown = true }
            Button(
                "What is the \(ordinal(self.store.value.count)) prime?",
                action: self.nthPrimeButtonAction
            )
            .disabled(self.isNthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
        .sheet(isPresented: self.$isPrimeModalShown) {
            IsPrimeModalView(store: self.store)
        }
        .alert(item: self.$alertNthPrime) { alert in
            Alert(
                title: Text("The \(ordinal(self.store.value.count)) prime is \(alert.prime)"),
                dismissButton: .default(Text("Ok"))
            )
        }
    }
    
    func nthPrimeButtonAction() {
        self.isNthPrimeButtonDisabled = true
        nthPrime(self.store.value.count) { prime in
            self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
            self.isNthPrimeButtonDisabled = false
        }
    }
}

struct IsPrimeModalView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        VStack {
            if isPrime(self.store.value.count) {
                Text("\(self.store.value.count) is prime 🎉")
                if self.store.value.favoritePrimes.contains(self.store.value.count) {
                    Button("Remove from favorite primes") {
                        self.store.send(.primeModal(.removeFavoritePrimeTapped))
                    }
                } else {
                    Button("Save to favorite primes") {
                        self.store.send(.primeModal(.saveFavoritePrimeTapped))
                    }
                }
            } else {
                Text("\(self.store.value.count) is not prime :(")
            }
        }
    }
}

struct FavoritePrimesView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        List {
            ForEach(self.store.value.favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                self.store.send(.favoritePrimes(.deleteFavoritePrimes(indexSet)))
            }
        }
        .navigationBarTitle("Favorite Primes")
    }
}

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    "Counter demo",
                    destination: CounterView(store: self.store)
                )
                NavigationLink(
                    "Favorite primes",
                    destination: FavoritePrimesView(store: self.store)
                )
            }
            .navigationBarTitle("State management")
        }
    }
}

#Preview {
    ContentView(
        store: Store(
            initialValue: AppState(),
            reducer: with(
                appReducer,
                compose(
                    logging,
                    activityFeed
                )
            )
        )
    )
}
