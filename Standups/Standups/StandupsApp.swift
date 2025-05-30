//
//  StandupsApp.swift
//  Standups
//
//  Created by 이승진 on 4/30/25.
//

import ComposableArchitecture
import SwiftUI

@main
struct StandupsApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppFeature.State(
                        path: StackState([
                            //              .detail(StandupDetailFeature.State(standup: .mock)),
                            //              .recordMeeting(RecordMeetingFeature.State()),
                        ]),
                        standupsList: StandupsListFeature.State(standups: [.mock])
                    )
                ) {
                    AppFeature()
                        ._printChanges()
                }
            )
        }
    }
}
