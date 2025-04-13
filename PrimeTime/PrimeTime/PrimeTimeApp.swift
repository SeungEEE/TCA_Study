//
//  PrimeTimeApp.swift
//  PrimeTime
//
//  Created by 이승진 on 4/13/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct PrimeTimeApp: App {
    var body: some Scene {
        WindowGroup {
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
    }
}
