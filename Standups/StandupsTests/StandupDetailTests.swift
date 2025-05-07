//
//  StandupDetailTests.swift
//  StandupsTests
//
//  Created by 이승진 on 5/7/25.
//

import ComposableArchitecture
import XCTest
@testable import Standups

//@MainActor
//final class StandupDetailTests: XCTestCase {
//    func testEdit() async throws {
//        var standup = Standup.mock
//        let store = TestStore(initialState: StandupDetailFeature.State(standup: standup)) {
//            StandupDetailFeature()
//        }
//        store.exhaustivity = .off
//        
//        await store.send(.editButtonTapped)
//        standup.title = "Point-Free Morning Sync"
//        await store.send(.editStandup(.presented(.set(\.$standup, standup))))
//        await store.send(.saveStandupButtonTapped) {
//            $0.standup.title = "Point-Free Morning Sync"
//        }
//    }
//}
