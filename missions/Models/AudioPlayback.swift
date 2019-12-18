//
//  AudioPlayback.swift
//  missions
//
//  Created by Elina Lua Ming on 12/17/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit
import AVFoundation

@available(iOS 13, *)
final class AudioPlayback: NSObject, AVAudioPlayerDelegate {
    
    private override init() {
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("error playing sound in AudioPlayback: \(error.localizedDescription)")
        }
        
    }
    
    static let shared = AudioPlayback()
    
    private(set) var audioPlayer = AVAudioPlayer()
    private(set) var playbackState: PlaybackState = .pause
    let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Lover", ofType: "mp3")!)
    
    func play(pan: Float) {
        
        if playbackState == .pause {
            audioPlayer.pan = pan
            playbackState = playbackState.toggle
            audioPlayer.play()
        } else if playbackState == .play {
            audioPlayer.pause()
            playbackState = playbackState.toggle
        }
        
    }
    
    func setPanValue(_ pan: Float) {
        
        audioPlayer.pan = pan
        
    }
    
    func skipToStart() {
        
        audioPlayer.currentTime = 0
        if playbackState == .play {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
        
    }
    
    func skipToEnd() {
        
        audioPlayer.currentTime = audioPlayer.duration
        audioPlayer.stop()
        
    }
    
}

