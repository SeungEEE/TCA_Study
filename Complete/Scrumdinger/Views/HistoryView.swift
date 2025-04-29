/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI

struct HistoryView: View {
    let history: History

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Divider()
                    .padding(.bottom)
                Text("Attendees")
                    .font(.headline)
                Text(history.attendeeString)
                if let transcript = history.transcript {
                    Text("Transcript")
                        .font(.headline)
                        .padding(.top)
                    Text(transcript)
                }
            }
        }
        .navigationTitle(Text(history.date, style: .date))
        .padding()
    }
}

extension History {
    var attendeeString: String {
        ListFormatter.localizedString(byJoining: attendees.map { $0.name })
    }
}

#Preview {
    let history = History(attendees: [
        Attendee(name: "Jon"),
        Attendee(name: "Darla"),
        Attendee(name: "Luis")
    ],
                          transcript: "Darla, would you like to start today? Sure, yesterday I reviewed Luis' PR and met with the design team to finalize the UI...")

    HistoryView(history: history)
}
