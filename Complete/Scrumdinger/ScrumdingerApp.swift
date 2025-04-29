/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI
import SwiftData

@main
struct ScrumdingerApp: App {

    var body: some Scene {
        WindowGroup {
            ScrumsView()
        }
        .modelContainer(for: DailyScrum.self)
    }
}
