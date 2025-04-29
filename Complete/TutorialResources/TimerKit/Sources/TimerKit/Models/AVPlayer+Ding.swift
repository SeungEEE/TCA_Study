/*
See LICENSE folder for this sample’s licensing information.
*/

import Foundation
import AVFoundation

extension AVPlayer {
    /// Returns an instance of `AVPlayer`, loaded to play the `ding` sound.
    public static func dingPlayer() -> AVPlayer {
        guard let url = Bundle.module.url(forResource: "ding", withExtension: "wav") else {
            fatalError("Failed to find sound file.")
        }
        return AVPlayer(url: url)
    }
}
