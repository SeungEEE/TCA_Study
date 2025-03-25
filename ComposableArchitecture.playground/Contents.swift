import Combine
import SwiftUI

struct WolframAlphaResult: Decodable {
    let queryresult: QueryResult
    
    struct QueryResult: Decodable {
        let pods: [Pod]
        
        struct Pod: Decodable {
            let primary: Bool?
            let subpods: [SubPod]
            
            struct SubPod: Decodable {
                let plaintext: String
            }
        }
    }
}

func wolframAlpha(query: String, callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
    var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
    components.queryItems = [
        URLQueryItem(name: "input", value: query),
        URLQueryItem(name: "format", value: "plaintext"),
        URLQueryItem(name: "output", value: "JSON"),
//        URLQueryItem(name: "appid", value: wolframAlphaApiKey),
    ]
    
    URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
        callback(
            data
                .flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0) }
        )
    }
    .resume()
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
    wolframAlpha(query: "prime \(n)") { result in
        callback(
            result
                .flatMap {
                    $0.queryresult
                        .pods
                        .first(where: { $0.primary == .some(true) })?
                        .subpods
                        .first?
                        .plaintext
                    
                }
                .flatMap(Int.init)
        )
    }
}

//nthPrime(1_100) { p in
//    print(p)
//}

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}

private func isPrime (_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrtf(Float(p))) {
        if p % i == 0 { return false }
    }
    return true
}

//BindableObject

struct AppState {
    var count = 0
    var favoritePrimes: [Int] = []
    var activityFeed: [Activity] = []
    var loggedInUser: User?
    
    struct Activity {
        let timestamp: Date
        let type: ActivityType
        
        enum ActivityType {
            case addedFavoritePrime(Int)
            case removedFavoritePrime(Int)
        }
    }
    
    struct User {
        let id: Int
        let name: String
        let bio: String
    }
}

enum CounterAction {
    case decrTapped
    case incrTapped
}

enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
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
someAction.counter
someAction.favoritePrimes

\AppAction.counter

// WritableKeyPath<AppAction, CounterAction?>

// (A) -> A
// (inout A) -> Void

// (A, B) -> (A, C)
// (inout A, B) -> C

// (Value, Action) -> Value
// (inout Value, Action) -> Void

func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped:
        state -= 1
        
    case .incrTapped:
        state += 1
    }
}

func primeModalReducer(state: inout AppState, action: PrimeModalAction) {
    switch action {
    case .removeFavoritePrimeTapped:
        state.favoritePrimes.removeAll(where: { $0 == state.count })
        state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
    case .saveFavoritePrimeTapped:
        state.favoritePrimes.append(state.count)
        state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
    }
}

struct FavoritePrimesState {
    var favoritePrimes: [Int]
    var activityFeed: [AppState.Activity]
}

func favoritePrimesReducer(state: inout FavoritePrimesState, action: FavoritePrimesAction) {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            let prime = state.favoritePrimes[index]
            state.favoritePrimes.remove(at: index)
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
        }
    }
}

//func appReducer(state: inout AppState, action: AppAction) -> Void {
//    switch action {
//    
//    }
//}

func combine<Value, Action>(
    _ reducers: (inout Value, Action) -> Void...
//    _ first: @escaping (inout Value, Action) -> Void,
//    _ second: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
    return { value, action in
        for reducer in reducers {
            reducer(&value, action)
        }
//        first(&value, action)
//        second(&value, action)
    }
}

final class Store<Value, Action>: ObservableObject {
    let reducer: (inout Value, Action) -> Void
    
    @Published var value: Value
    
    init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.reducer = reducer
        self.value = initialValue
    }
    
    func send(_ action: Action) {
        self.reducer(&self.value, action)
    }
}

func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction> (
    _ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {
    
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return }
        reducer(&globalValue[keyPath: value], localAction)
    }
}

extension AppState {
    var favoritePrimesState: FavoritePrimesState {
        get {
            return FavoritePrimesState(
                favoritePrimes: self.favoritePrimes,
                activityFeed: self.activityFeed
            )
        }
        set {
            self.favoritePrimes = newValue.favoritePrimes
            self.activityFeed  = newValue.activityFeed
        }
    }
}

struct _KeyPath<Root, Value> {
    let get: (Root) -> Value
    let set: (inout Root, Value) -> Void
}

AppAction.counter(CounterAction.incrTapped)

let action = AppAction.favoritePrimes(.deleteFavoritePrimes([1]))
let favoritePrimes: FavoritePrimesAction?
switch action {
case let .favoritePrimes(action):
    favoritePrimes = action
default:
    favoritePrimes = nil
}

struct EnumKeyPath<Root, Value> {
    let embed: (Value) -> Root
    let extract: (Root) -> Value?
}

// \AppAction.counter // EnumKeyPath<AppAction, CounterAction>

let _appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(counterReducer, value: \.count, action: \.counter),
    pullback(primeModalReducer, value: \.self, action: \.primeModal),
    pullback(favoritePrimesReducer, value: \.favoritePrimesState, action: \.favoritePrimes)
)

let appReducer = pullback(_appReducer, value: \.self, action: \.self)
// combine(combine(counterReducer, primeModalReducer), favoritePrimesReducer)

// [1, 2, 3].reduce(<#T##initialResult: Result##Result#>, <#T##nextPartialResult: (Result, Int) throws -> Result##(Result, Int) throws -> Result##(_ partialResult: Result, Int) throws -> Result#>)

var state = AppState()
//counterReducer(state: &state, action: .incrTapped)
//counterReducer(state: &state, action: .decrTapped)

//print(
//    counterReducer(
//        state: counterReducer(state: state, action: .incrTapped),
//        action: .decrTapped
//    )
//)

//counterReducer(state: state, action: .incrTapped)


// Store<AppState>

// @ObservedObject var state: AppState
// -> @ObservedObject var store: Store<AppState>

// self.state
// -> self.store.value

// (state: self.store.value)
// -> (store: self.store)

struct PrimeAlert: Identifiable {
    let prime: Int
    var id: Int { self.prime }
}

struct CounterView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: PrimeAlert?
    @State var isNthPrimeButtonDisabled = false
    
    var body: some View {
        VStack {
            HStack {
                Button("-") { self.store.send(.counter(.decrTapped)) }
                Text("\(self.store.value.count)")
                Button("+") { self.store.send(.counter(.incrTapped)) }
            }
            
            Button(action: { self.isPrimeModalShown = true}) {
                Text("Is this prime")
            }
            
            Button(action: self.nthPrimeButtonAction) {
                Text("What is the \(ordinal(self.store.value.count))th prime?")
            }
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
                dismissButton: .default(Text("ok"))
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
                Text("\(self.store.value.count) is prime!!")
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

extension AppState {
    var favoritePrimeState: FavoritePrimesState {
        get {
            FavoritePrimesState(
                favoritePrimes: self.favoritePrimes,
                activityFeed: self.activityFeed
            )
        }
        set {
            self.favoritePrimes = newValue.favoritePrimes
            self.activityFeed = newValue.activityFeed
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
            .navigationBarTitle(Text("Favorite Primes"))
    }
}

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: CounterView(store: self.store)
                ) {
                    Text("Counter demo")
                }
                
                NavigationLink(destination: FavoritePrimesView(
                    store: self.store)
                ) {
                    Text("Favorite primes")
                }
            }
            .navigationBarTitle("State management")
        }
    }
}

import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(
    rootView:  ContentView(
        store: Store(initialValue: AppState(), reducer: appReducer)
    )
)

