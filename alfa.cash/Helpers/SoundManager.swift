//
//  SoundManager.swift
//  alfa.cash
//
//  Created by Anna on 8/4/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import AVFoundation

class SoundManager: NSObject {
    static var player = AVAudioPlayer()
    
    static func play(soundType: SoundType) {
        
        guard let path = Bundle.main.path(forResource: soundType.rawValue, ofType: "wav") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print(error)
        }
        player.play()
    }
}

enum SoundType: String {
    case send
    case receive
}
