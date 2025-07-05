//
//  Sound.swift
//  SoundCraft
//
//  Created by Abe Malla on 7/4/25.
//

import Foundation

struct Sound: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    var volume: Double = 0.5
    var isPlaying: Bool = true
}
