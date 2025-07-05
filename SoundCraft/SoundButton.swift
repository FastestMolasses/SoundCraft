//
//  SoundButton.swift
//  SoundCraft
//
//  Created by Abe Malla on 7/4/25.
//

import SwiftUI

struct SoundButton: View {
    @Binding var sound: Sound
    let onDelete: () -> Void

    var body: some View {
        Button(action: {
            withAnimation {
                sound.isPlaying.toggle()
            }
        }) {
            Image(systemName: sound.icon)
                .font(.system(size: 24))
                .frame(width: 150, height: 80)
                .foregroundStyle(.foreground)
                .glassEffect()
        }
        .glassEffect()
    }
}
