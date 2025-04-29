/*
See LICENSE folder for this sample’s licensing information.
*/

import Foundation

/// Keeps time for a daily scrum meeting. Keep track of the total meeting time, the time for each speaker, and the name of the current speaker.

@MainActor
@Observable public final class ScrumTimer {
    /// A struct to keep track of meeting attendees during a meeting.
    public struct Speaker: Identifiable {
        /// The attendee name.
        public let name: String
        /// True if the attendee has completed their turn to speak.
        public var isCompleted: Bool
        /// Id for Identifiable conformance.
        public let id = UUID()

        public init(name: String, isCompleted: Bool) {
            self.name = name
            self.isCompleted = isCompleted
        }
    }
    
    /// The name of the meeting attendee who is speaking.
    public var activeSpeaker = ""
    /// The number of seconds since the beginning of the meeting.
    public var secondsElapsed = 0
    /// The number of seconds until all attendees have had a turn to speak.
    public var secondsRemaining = 0
    /// All meeting attendees, listed in the order they will speak.
    private var _speakers: [Speaker] = []
    /// Public accessor for the speakers at the meeting.
    public var speakers: [Speaker] {
        _speakers
    }
    /// A closure that is executed when a new attendee begins speaking.
    public var speakerChangedAction: (() -> Void)?

    /// The scrum meeting length.
    private var lengthInMinutes: Int
    private weak var timer: Timer?
    private var timerStopped = false
    private var frequency: TimeInterval { 1.0 / 60.0 }
    private var lengthInSeconds: Int { lengthInMinutes * 60 }
    private var secondsPerSpeaker: Int {
        (lengthInMinutes * 60) / _speakers.count
    }
    private var secondsElapsedForSpeaker: Int = 0
    private var speakerIndex: Int = 0
    private var speakerText: String {
        return "Speaker \(speakerIndex + 1): " + _speakers[speakerIndex].name
    }
    private var startDate: Date?
    
    /**
     Initialize a new timer. Initializing a time with no arguments creates a ScrumTimer with no attendees and zero length.
     Use `startScrum()` to start the timer.
     
     - Parameters:
        - lengthInMinutes: The meeting length.
        - attendeeNames: A list of attendee names for the meeting.
     */
    public init(lengthInMinutes: Int = 0, attendeeNames: [String] = []) {
        self.lengthInMinutes = lengthInMinutes
        self._speakers = Self.generateSpeakersList(with: attendeeNames)
        secondsRemaining = lengthInSeconds
        activeSpeaker = speakerText
    }
    
    /// Start the timer.
    public func startScrum() {
        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] timer in
            self?.update()
        }
        timer?.tolerance = 0.1
        changeToSpeaker(at: 0)
    }
    
    /// Stop the timer.
    public func stopScrum() {
        timer?.invalidate()
        timerStopped = true
    }
    
    /// Advance the timer to the next speaker.
    nonisolated public func skipSpeaker() {
        Task { @MainActor in
            changeToSpeaker(at: speakerIndex + 1)
        }
    }

    /**
     Reset the timer with a new meeting length and new attendees.
     
     - Parameters:
         - lengthInMinutes: The meeting length.
         - attendees: The name of each attendee.
     */
    public func reset(lengthInMinutes: Int, attendeeNames: [String]) {
        self.lengthInMinutes = lengthInMinutes
        self._speakers = Self.generateSpeakersList(with: attendeeNames)
        secondsRemaining = lengthInSeconds
        activeSpeaker = speakerText
    }

    private func changeToSpeaker(at index: Int) {
        if index > 0 {
            let previousSpeakerIndex = index - 1
            _speakers[previousSpeakerIndex].isCompleted = true
        }
        secondsElapsedForSpeaker = 0
        guard index < _speakers.count else { return }
        speakerIndex = index
        activeSpeaker = speakerText

        secondsElapsed = index * secondsPerSpeaker
        secondsRemaining = lengthInSeconds - secondsElapsed
        startDate = Date()
    }

    nonisolated private func update() {

        Task { @MainActor in
            guard let startDate,
                  !timerStopped else { return }
            let secondsElapsed = Int(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
            secondsElapsedForSpeaker = secondsElapsed
            self.secondsElapsed = secondsPerSpeaker * speakerIndex + secondsElapsedForSpeaker
            guard secondsElapsed <= secondsPerSpeaker else {
                return
            }
            secondsRemaining = max(lengthInSeconds - self.secondsElapsed, 0)

            if secondsElapsedForSpeaker >= secondsPerSpeaker {
                changeToSpeaker(at: speakerIndex + 1)
                speakerChangedAction?()
            }
        }
    }

    /**
     Generates a speaker list from a list of names.

     - Parameters:
        - names: An array of `String`s representing people's names

     - Returns: An array of `Speaker`s, or a single generic `Speaker` if the `names` parameter is empty
     */
    private static func generateSpeakersList(with names: [String]) -> [Speaker] {
        guard !names.isEmpty else { return [Speaker(name: "Speaker 1", isCompleted: false)] }
        return names.map { Speaker(name: $0, isCompleted: false) }
    }
}
